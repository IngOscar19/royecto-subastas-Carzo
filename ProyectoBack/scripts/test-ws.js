const { io } = require('socket.io-client');

const auctionId = process.argv[2] || process.env.AUCTION_ID || '00000000-0000-4000-8000-000000000001';
const wsUrl = process.env.WS_URL || 'http://localhost:3000';
const TIMEOUT_MS = 10_000;

const socket = io(wsUrl, { transports: ['websocket'] });

let settled = false;

function finish(code) {
  if (settled) return;
  settled = true;
  socket.close();
  process.exit(code);
}

function log(label, payload) {
  console.log(`[${new Date().toISOString()}] ${label}`);
  console.log(JSON.stringify(payload, null, 2));
}

socket.on('connect', () => {
  console.log(`[${new Date().toISOString()}] connected to ${wsUrl} (socket ${socket.id})`);
  socket.emit('join_auction', { auctionId });
  log('emit join_auction', { auctionId });
});

socket.on('auction_snapshot', (payload) => {
  log('auction_snapshot', payload);
  finish(0);
});

socket.on('auction_error', (payload) => {
  log('auction_error', payload);
  finish(1);
});

socket.on('disconnect', (reason) => {
  console.log(`[${new Date().toISOString()}] disconnected: ${reason}`);
  finish(1);
});

socket.on('connect_error', (err) => {
  console.error(`[${new Date().toISOString()}] connect_error: ${err.message}`);
  finish(1);
});

setTimeout(() => {
  console.error(`[${new Date().toISOString()}] timeout: no response in ${TIMEOUT_MS}ms`);
  finish(1);
}, TIMEOUT_MS);
