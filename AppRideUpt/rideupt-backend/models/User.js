// models/User.js
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const vehicleSchema = new mongoose.Schema({
  make: { type: String, required: true }, // Marca (ej. Toyota)
  model: { type: String, required: true }, // Modelo (ej. Yaris)
  year: { type: Number, required: true },
  color: { type: String, required: true },
  licensePlate: { type: String, required: true }, // Placa (validación de unicidad se hará en el controlador)
  totalSeats: { type: Number, required: true, min: 1, max: 8 }, // Total de asientos disponibles (1-8)
});

const userSchema = new mongoose.Schema({
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  email: { type: String, required: true, unique: true, lowercase: true },
  password: { type: String, required: true },
  phone: { type: String, default: 'Pendiente' },
  university: { type: String, required: true },
  studentId: { type: String, required: true },
  
  // Nuevos campos editables
  age: { type: Number, min: 16, max: 100 }, // Edad (mínimo 16 años)
  gender: { type: String, enum: ['masculino', 'femenino', 'otro', 'prefiero_no_decir'], default: 'prefiero_no_decir' },
  bio: { type: String, maxlength: 500 }, // Biografía corta
  
  role: { type: String, enum: ['passenger', 'driver'], default: 'passenger' },
  profilePhoto: { type: String, default: 'default_avatar.png' },
  isDriverProfileComplete: { type: Boolean, default: false },
  vehicle: vehicleSchema, // Datos del vehículo, solo si es conductor
  fcmToken: { type: String }, // Para notificaciones push
}, {
  timestamps: true
});

// Hashear la contraseña antes de guardar
userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) {
    return next();
  }
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

// Método para comparar contraseñas en el login
userSchema.methods.comparePassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

// Índice único SPARSE en vehicle.licensePlate
// Solo se aplica a documentos que tienen este campo (drivers con vehículo)
// Permite múltiples documentos sin vehículo (pasajeros)
userSchema.index({ 'vehicle.licensePlate': 1 }, { 
  unique: true, 
  sparse: true,
  partialFilterExpression: { 'vehicle.licensePlate': { $exists: true, $ne: null } }
});

module.exports = mongoose.model('User', userSchema);