const net = require('net');
const { SocksClient } = require('socks');

const LOCAL_PORT = 80;
const POOL_HOST = 'mine.pool.r4nd0m.us';
const POOL_PORT = 6991;
const SOCKS5_HOST = '45.115.224.103';
const SOCKS5_PORT = 1080;

console.log(`🕵️ Stealth Proxy active on 127.0.0.1:${LOCAL_PORT}`);

const server = net.createServer((client) => {
    console.log('Miner connected to local proxy');
    
    SocksClient.createConnection({
        proxy: { host: SOCKS5_HOST, port: SOCKS5_PORT, type: 5 },
        command: 'connect',
        destination: { host: POOL_HOST, port: POOL_PORT }
    }).then(info => {
        const pool = info.socket;
        client.pipe(pool);
        pool.pipe(client);
        
        client.on('error', () => pool.destroy());
        pool.on('error', () => client.destroy());
    }).catch(err => {
        console.error('SOCKS5 Error:', err.message);
        client.destroy();
    });
});

server.listen(LOCAL_PORT, '0.0.0.0');
