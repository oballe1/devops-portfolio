# DevOps Portfolio - Full Stack Deployment

A production-ready DevOps portfolio website with dynamic features, built for Docker deployment and internet accessibility.

## 🚀 Quick Start

```bash
git clone <your-repo-url>
cd devops-portfolio
cp .env.example .env  # Edit with your settings
docker-compose up -d
```

Visit: http://localhost

## 📋 Features

### Frontend
- Responsive HTML5/CSS3/JavaScript portfolio
- Interactive contact form with backend integration
- Dynamic blog comment system
- Real-time page analytics

### Backend
- Node.js/Express REST API
- MySQL database with full schema
- Rate limiting and security headers
- Automated backups and health monitoring

### DevOps/Deployment
- Multi-service Docker Compose setup
- Nginx reverse proxy with SSL support
- Database persistence and automated backups
- Multiple internet accessibility options (ngrok, Cloudflare Tunnel, etc.)

## 📚 Documentation

- **[Docker Deployment Guide](DOCKER-DEPLOYMENT-GUIDE.md)** - Complete local deployment instructions
- **[Internet Access Guide](INTERNET-ACCESS-GUIDE.md)** - Make your site accessible from anywhere
- **[AWS Setup](AWS-SETUP.md)** - Cloud deployment instructions
- **[Production Ready Guide](PRODUCTION-READY.md)** - Enterprise deployment checklist

## 🏗️ Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Frontend  │    │  Backend    │    │  Database   │
│   (Nginx)   │────│ (Node.js)   │────│  (MySQL)    │
│   Port 80   │    │  Port 3000  │    │  Port 3306  │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       └───────────────────┼───────────────────┘
                           │
                  ┌─────────────┐
                  │   Optional  │
                  │   Services  │
                  │ (Redis/PHP- │
                  │  MyAdmin)   │
                  └─────────────┘
```

## 🛠️ Local Development

```bash
# Start with development tools
docker-compose --profile development up -d

# Access services:
# - Website: http://localhost
# - API: http://localhost:3000
# - DB Admin: http://localhost:8080
```

## 🌐 Internet Access Options

1. **ngrok** (Fastest) - `ngrok http 80`
2. **Cloudflare Tunnel** (Free, Custom Domain)
3. **Router Port Forwarding** (Traditional)
4. **VPS Reverse Proxy** (Production)

See [Internet Access Guide](INTERNET-ACCESS-GUIDE.md) for details.

## 🔒 Security Features

- Rate limiting on all endpoints
- SQL injection prevention
- XSS protection headers
- Input validation and sanitization
- Secure password hashing
- CORS configuration

## 📊 Monitoring & Maintenance

```bash
# View logs
docker-compose logs -f

# Health checks
curl http://localhost/health
curl http://localhost:3000/health

# Database backups (if backup profile enabled)
docker-compose exec mysql-backup /backup.sh

# Update deployment
git pull && docker-compose up -d --build
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with `docker-compose up -d`
5. Submit a pull request

## 📝 License

MIT License - see LICENSE file for details.

## 🆘 Support

- Check the troubleshooting sections in the deployment guides
- View logs: `docker-compose logs [service-name]`
- Reset deployment: `docker-compose down -v && docker-compose up -d`
