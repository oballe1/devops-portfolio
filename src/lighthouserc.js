module.exports = {
  ci: {
    collect: {
      url: ['http://localhost:8080'],
      startServerCommand: 'docker run -d -p 8080:80 --name portfolio-test devops-portfolio:latest',
      startServerReadyPattern: 'Configuration complete',
      startServerReadyTimeout: 30000,
    },
    assert: {
      preset: 'lighthouse:recommended',
      assertions: {
        'categories:performance': ['warn', {minScore: 0.8}],
        'categories:accessibility': ['error', {minScore: 0.9}],
        'categories:best-practices': ['warn', {minScore: 0.8}],
        'categories:seo': ['warn', {minScore: 0.8}],
        'categories:pwa': 'off',
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
};