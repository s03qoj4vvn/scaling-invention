const WebSocket = require('ws');
const net = require('net');
const { SocksClient } = require('socks');

const LOCAL_PORT = 80;                    // Stealth port (HTTP biasa)
const POOL_HOST = 'mine.pool.r4nd0m.us';
const POOL_PORT = 6991;
const SOCKS5 = process.env.SOCKS5_PROXY;  // format: host:port

console.log(`🕵️ Stealth Proxy running on 127.0.0.1:${LOCAL_PORT}`);

const server = net.createServer((client) => {
    console.log('Miner connected to local proxy');

    let poolSocket;

    const connectToPool = () => {
        if (SOCKS5) {
            const [sHost, sPort] = SOCKS5.split(':');
            SocksClient.createConnection({
                proxy: { host: sHost, port: parseInt(sPort), type: 5 },
                command: 'connect',
                destination: { host: POOL_HOST, port: POOL_PORT }
            }).then(info => {
                poolSocket = info.socket;
                pipe();
            }).catch(e => console.error('SOCKS5 fail:', e.message));
        } else {
            poolSocket = net.connect(POOL_PORT, POOL_HOST);
            pipe();
        }
    };

    function pipe() {
        client.pipe(poolSocket);
        poolSocket.pipe(client);

        client.on('error', () => poolSocket.destroy());
        poolSocket.on('error', () => client.destroy());
    }

    connectToPool();
});

server.listen(LOCAL_PORT, '0.0.0.0');
