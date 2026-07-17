const net = require('net');
const { SocksClient } = require('socks');

const LOCAL_PORT = 80;
const POOL_HOST = 'mine.pool.r4nd0m.us';
const POOL_PORT = 6991;
const SOCKS5_HOST = '45.115.224.103';
const SOCKS5_PORT = 1080;

console.log(`🕵️ Stealth Proxy running on 127.0.0.1:${LOCAL_PORT} → SOCKS5 ${SOCKS5_HOST}:${SOCKS5_PORT}`);

const server = net.createServer((client) => {
    console.log('Miner connected');

    SocksClient.createConnection({
        proxy: { host: SOCKS5_HOST, port: SOCKS5_PORT, type: 5 },
        command: 'connect',
        destination: { host: POOL_HOST, port: POOL_PORT }
    }).then(info => {
        const poolSocket = info.socket;

        client.pipe(poolSocket);
        poolSocket.pipe(client);

        client.on('error', () => poolSocket.destroy());
        poolSocket.on('error', () => client.destroy());
    }).catch(err => {
        console.error('SOCKS5 connection error:', err.message);
        client.destroy();
    });
});

server.listen(LOCAL_PORT, '0.0.0.0');
