const express = require('express');
const fs = require('fs');
const path = require('path');
const net = require('net');

const app = express();
const PORT = 3001;
// const NGINX_CONFIG_PATH = path.join(__dirname, '../nginx/llm.kortexa.ai');
const NGINX_CONFIG_PATH = '/etc/nginx/sites-available/llm.kortexa.ai';

function parseNginxConfig() {
    const content = fs.readFileSync(NGINX_CONFIG_PATH, 'utf8');
    const lines = content.split(/\r?\n/);
    let inHttpsServer = false;
    let braceDepth = 0;
    let currentServerName = null;
    const locations = [];
    let lastLocation = null;
    for (let i = 0; i < lines.length; i++) {
        let line = lines[i].trim();
        // Detect start of HTTPS server block
        if (line.startsWith('server {')) {
            // Look ahead for 'listen 443' or 'listen [::]:443'
            let j = i + 1;
            let found443 = false;
            let serverName = null;
            while (j < lines.length && lines[j].indexOf('{') === -1 && lines[j].indexOf('}') === -1) {
                if (lines[j].includes('listen 443') || lines[j].includes('listen [::]:443')) {
                    found443 = true;
                }
                let m = lines[j].match(/^server_name\s+(\S+);/);
                if (m) serverName = m[1];
                j++;
            }
            if (found443) {
                inHttpsServer = true;
                braceDepth = 1;
                currentServerName = serverName;
                i = j - 1;
                continue;
            }
        }
        if (inHttpsServer) {
            if (line.includes('{')) braceDepth += (line.match(/{/g) || []).length;
            if (line.includes('}')) braceDepth -= (line.match(/}/g) || []).length;
            let m = line.match(/^location\s+([\/\w\-]+)\s*{/);
            if (m) {
                lastLocation = m[1];
                // Look ahead for comments after location {
                let model = null;
                let description = null;
                let k = i + 1;
                while (k < lines.length) {
                    let nextLine = lines[k].trim();
                    if (nextLine.startsWith('#')) {
                        if (nextLine.match(/^#\s*Model:\s*(.+)$/i)) {
                            model = nextLine.replace(/^#\s*Model:\s*/i, '').trim();
                        } else if (!description) {
                            description = nextLine.replace(/^#\s*/, '').trim();
                        }
                        k++;
                    } else if (nextLine.length === 0) {
                        k++;
                    } else {
                        break;
                    }
                }
                locations.push({ location: lastLocation, proxy_pass: null, server_name: currentServerName, model, description });
            }
            m = line.match(/^proxy_pass\s+(http[s]?:\/\/\S+);/);
            if (m && lastLocation) {
                let idx = locations.findIndex(l => l.location === lastLocation && l.server_name === currentServerName);
                if (idx !== -1) locations[idx].proxy_pass = m[1];
            }
            if (braceDepth === 0) {
                inHttpsServer = false;
                currentServerName = null;
            }
        }
    }
    const models = [];
    for (const info of locations) {
        if (info.proxy_pass) {
            const m = info.proxy_pass.match(/^http[s]?:\/\/([\w\.-]+):(\d+)/);
            models.push({
                location: info.location,
                backend_url: info.proxy_pass,
                host: m ? m[1] : null,
                port: m ? parseInt(m[2], 10) : null,
                server_name: info.server_name,
                model: info.model,
                description: info.description
            });
        }
    }
    return models;
}

function isUp(host, port, timeout = 500) {
    return new Promise((resolve) => {
        if (!host || !port) return resolve(false);
        const socket = new net.Socket();
        let called = false;
        socket.setTimeout(timeout);
        socket.on('connect', () => {
            called = true;
            socket.destroy();
            resolve(true);
        });
        socket.on('timeout', () => {
            if (!called) {
                called = true;
                socket.destroy();
                resolve(false);
            }
        });
        socket.on('error', () => {
            if (!called) {
                called = true;
                resolve(false);
            }
        });
        socket.connect(port, host);
    });
}

app.use(express.static(path.join(__dirname, '..')));

app.get('/api/models', async (req, res) => {
    const models = parseNginxConfig();
    await Promise.all(models.map(async (model) => {
        model.up = await isUp(model.host, model.port);
        model.public_url = model.server_name ? `https://${model.server_name}${model.location}` : null;
    }));
    res.json(models);
});

app.listen(PORT, () => {
    console.log(`LLM Dashboard server running at http://localhost:${PORT}`);
});
