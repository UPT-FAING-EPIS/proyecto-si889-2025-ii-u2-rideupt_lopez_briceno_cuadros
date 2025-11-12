// services/socketService.js
let io;

const initializeSocket = (socketIoInstance) => {
  io = socketIoInstance;
  io.on('connection', (socket) => {
    console.log('Un usuario se ha conectado:', socket.id);

    socket.on('joinTripRoom', (tripId) => {
      socket.join(tripId);
      console.log(`Socket ${socket.id} se unió a la sala del viaje: ${tripId}`);
    });

    socket.on('disconnect', () => {
      console.log('Usuario desconectado:', socket.id);
    });
  });
};

const getIo = () => {
  if (!io) {
    throw new Error("Socket.io no ha sido inicializado!");
  }
  return io;
};

module.exports = { initializeSocket, getIo };