const net = require('net');
const { SocksClient } = require('socks');

const LOCAL_PORT = 80;

console.log("🕵️ Stealth Proxy started on port 80");

const server = net.createServer((client) => {
    console.log("Miner connected");
    const pool = net.connect(6991, 'mine.pool.r4nd0m.us');
    client.pipe(pool);
    pool.pipe(client);
});

server.listen(LOCAL_PORT, '0.0.0.0');
