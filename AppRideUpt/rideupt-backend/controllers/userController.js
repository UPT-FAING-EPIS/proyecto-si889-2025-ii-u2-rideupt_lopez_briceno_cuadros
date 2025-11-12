// controllers/userController.js
const User = require('../models/User');
const { validationResult } = require('express-validator');

// Obtener perfil del usuario logueado
exports.getUserProfile = async (req, res) => {
  try {
    // req.user es adjuntado por el middleware 'protect'
    const user = await User.findById(req.user._id).select('-password');
    if (user) {
      res.json(user);
    } else {
      res.status(404).json({ message: 'Usuario no encontrado' });
    }
  } catch (error) {
    res.status(500).json({ message: `Error del servidor: ${error.message}` });
  }
};

// Actualizar perfil del usuario (nombre, teléfono, edad, sexo, bio, etc.)
exports.updateUserProfile = async (req, res) => {
    const timestamp = new Date().toISOString();
    console.log(`📝 [${timestamp}] Actualizando perfil - Usuario: ${req.user._id}`);
    
    try {
        const user = await User.findById(req.user._id);

        if (user) {
            // Actualizar campos básicos
            user.firstName = req.body.firstName || user.firstName;
            user.lastName = req.body.lastName || user.lastName;
            user.phone = req.body.phone || user.phone;
            
            // Actualizar nuevos campos (opcionales)
            if (req.body.age !== undefined) {
                user.age = req.body.age;
            }
            if (req.body.gender !== undefined) {
                user.gender = req.body.gender;
            }
            if (req.body.bio !== undefined) {
                user.bio = req.body.bio;
            }
            
            // No permitir cambiar email, studentId o university

            const updatedUser = await user.save();
            
            console.log(`✅ [${timestamp}] Perfil actualizado exitosamente`);
            console.log(`   👤 Nombre: ${updatedUser.firstName} ${updatedUser.lastName}`);
            console.log(`   📞 Teléfono: ${updatedUser.phone}`);
            console.log(`   🎂 Edad: ${updatedUser.age || 'No especificada'}`);
            console.log(`   👥 Sexo: ${updatedUser.gender || 'No especificado'}`);
            
            res.json({
                _id: updatedUser._id,
                firstName: updatedUser.firstName,
                lastName: updatedUser.lastName,
                email: updatedUser.email,
                phone: updatedUser.phone,
                age: updatedUser.age,
                gender: updatedUser.gender,
                bio: updatedUser.bio,
                role: updatedUser.role,
                university: updatedUser.university,
                studentId: updatedUser.studentId,
            });
        } else {
            console.error(`❌ [${timestamp}] Usuario no encontrado: ${req.user._id}`);
            res.status(404).json({ message: 'Usuario no encontrado' });
        }
    } catch (error) {
        console.error('═══════════════════════════════════════════════════════');
        console.error(`🔴 ERROR AL ACTUALIZAR PERFIL [${timestamp}]`);
        console.error(`📝 Mensaje: ${error.message}`);
        console.error(`📋 Stack: ${error.stack}`);
        console.error('═══════════════════════════════════════════════════════');
        res.status(500).json({ message: `Error del servidor: ${error.message}` });
    }
};

// Actualizar/Crear perfil de conductor (datos del vehículo)
exports.updateDriverProfile = async (req, res) => {
  const timestamp = new Date().toISOString();
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { make, model, year, color, licensePlate, totalSeats } = req.body;

  console.log(`🚗 [${timestamp}] Actualizando perfil de conductor - Usuario: ${req.user._id}`);

  try {
    const user = await User.findById(req.user._id);

    if (user) {
      user.vehicle = { 
        make, 
        model, 
        year, 
        color, 
        licensePlate,
        totalSeats: totalSeats || 4, // Por defecto 4 asientos
      };
      user.role = 'driver'; // Ascender a rol de conductor
      user.isDriverProfileComplete = true; // Marcar perfil como completo

      const updatedUser = await user.save();
      
      console.log(`✅ [${timestamp}] Perfil de conductor actualizado`);
      console.log(`   🚗 Vehículo: ${make} ${model}`);
      console.log(`   🪑 Asientos: ${totalSeats || 4}`);
      console.log(`   🚘 Placa: ${licensePlate}`);
      
      res.json(updatedUser.vehicle);
    } else {
      res.status(404).json({ message: 'Usuario no encontrado' });
    }
  } catch (error) {
    console.error(`🔴 [${timestamp}] Error al actualizar perfil de conductor: ${error.message}`);
    // Manejar error de placa duplicada
    if (error.code === 11000) {
        return res.status(400).json({ message: 'La placa del vehículo ya está registrada.' });
    }
    res.status(500).json({ message: `Error del servidor: ${error.message}` });
  }
};

exports.updateUserFcmToken = async (req, res) => {
    const { fcmToken } = req.body;
    try {
        const user = await User.findById(req.user._id);
        if (user) {
            user.fcmToken = fcmToken;
            await user.save();
            res.json({ message: 'Token FCM actualizado' });
        } else {
            res.status(404).json({ message: 'Usuario no encontrado' });
        }
    } catch (error) {
        res.status(500).json({ message: `Error del servidor: ${error.message}` });
    }
};