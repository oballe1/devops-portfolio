#!/bin/sh

# Database backup script for Docker environment
# Runs daily backups with retention policy

set -e

# Configuration from environment variables
DB_HOST=${DB_HOST:-mysql}
DB_USER=${DB_USER:-portfolio_user}
DB_PASSWORD=${DB_PASSWORD:-portfolio_password}
DB_NAME=${DB_NAME:-devops_portfolio}
BACKUP_RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-30}
BACKUP_DIR="/backups"

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to create database backup
create_backup() {
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="${BACKUP_DIR}/portfolio_backup_${timestamp}.sql"
    local compressed_file="${backup_file}.gz"

    log "Starting database backup for ${DB_NAME}"

    # Wait for database to be ready
    while ! mysqladmin ping -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" --silent; do
        log "Waiting for database to be ready..."
        sleep 5
    done

    # Create the backup
    if mysqldump -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" \
        --single-transaction \
        --routines \
        --triggers \
        --complete-insert \
        --extended-insert \
        --add-drop-database \
        --databases "${DB_NAME}" > "${backup_file}"; then

        # Compress the backup
        gzip "${backup_file}"
        log "Backup created successfully: ${compressed_file}"

        # Set proper permissions
        chmod 600 "${compressed_file}"

        # Cleanup old backups
        cleanup_old_backups
    else
        log "ERROR: Backup failed"
        rm -f "${backup_file}"
        exit 1
    fi
}

# Function to cleanup old backups
cleanup_old_backups() {
    log "Cleaning up backups older than ${BACKUP_RETENTION_DAYS} days"

    find "${BACKUP_DIR}" -name "portfolio_backup_*.sql.gz" -type f -mtime +${BACKUP_RETENTION_DAYS} -delete

    local remaining_backups=$(find "${BACKUP_DIR}" -name "portfolio_backup_*.sql.gz" -type f | wc -l)
    log "Cleanup completed. ${remaining_backups} backup files remaining"
}

# Function to restore from backup
restore_backup() {
    local backup_file="$1"

    if [ -z "$backup_file" ]; then
        log "ERROR: Please provide backup file path"
        exit 1
    fi

    if [ ! -f "$backup_file" ]; then
        log "ERROR: Backup file not found: $backup_file"
        exit 1
    fi

    log "Starting database restore from: $backup_file"

    # If it's a gzipped file, decompress first
    if [[ "$backup_file" == *.gz ]]; then
        gunzip -c "$backup_file" | mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}"
    else
        mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" < "$backup_file"
    fi

    log "Database restore completed successfully"
}

# Function to list available backups
list_backups() {
    log "Available backups:"
    find "${BACKUP_DIR}" -name "portfolio_backup_*.sql.gz" -type f -printf "%T@ %Tc %p\n" | sort -n | cut -d' ' -f2-
}

# Function to verify backup integrity
verify_backup() {
    local backup_file="$1"

    if [ -z "$backup_file" ]; then
        log "ERROR: Please provide backup file path"
        exit 1
    fi

    if [[ "$backup_file" == *.gz ]]; then
        if gunzip -t "$backup_file" 2>/dev/null; then
            log "Backup file integrity: OK"
            return 0
        else
            log "Backup file integrity: FAILED"
            return 1
        fi
    else
        log "Backup file integrity: OK (uncompressed)"
        return 0
    fi
}

# Create crontab for automated backups
setup_cron() {
    # Create crontab entry for daily backups at 2 AM
    echo "0 2 * * * /backup.sh backup >> /var/log/backup.log 2>&1" | crontab -
    log "Cron job for daily backups has been set up"
}

# Main script logic
case "${1:-backup}" in
    "backup")
        create_backup
        ;;
    "restore")
        restore_backup "$2"
        ;;
    "list")
        list_backups
        ;;
    "verify")
        verify_backup "$2"
        ;;
    "setup-cron")
        setup_cron
        ;;
    "help"|"--help"|"-h")
        echo "Usage: $0 [backup|restore|list|verify|setup-cron|help]"
        echo ""
        echo "Commands:"
        echo "  backup          Create a database backup (default)"
        echo "  restore <file>  Restore from a backup file"
        echo "  list            List available backups"
        echo "  verify <file>   Verify backup file integrity"
        echo "  setup-cron      Set up automated daily backups"
        echo "  help            Show this help message"
        ;;
    *)
        log "ERROR: Unknown command: $1"
        log "Use '$0 help' for usage information"
        exit 1
        ;;
esac