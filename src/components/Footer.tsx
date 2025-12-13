import React from 'react';
import { Heart, Mail, Globe } from 'lucide-react';

export const Footer: React.FC = () => {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="bg-gray-800 text-white mt-auto">
      <div className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-8">
          <div>
            <h3 className="text-2xl font-bold mb-4 text-emerald-400">Zootopia</h3>
            <p className="text-gray-300 leading-relaxed">
              Descubre y aprende sobre la increíble biodiversidad de nuestro planeta.
              Protegiendo especies, preservando ecosistemas.
            </p>
          </div>

          <div>
            <h4 className="text-lg font-semibold mb-4">Enlaces Rápidos</h4>
            <ul className="space-y-2">
              <li>
                <a href="/" className="text-gray-300 hover:text-emerald-400 transition">
                  Inicio
                </a>
              </li>
              <li>
                <a href="/login" className="text-gray-300 hover:text-emerald-400 transition">
                  Iniciar Sesión
                </a>
              </li>
              <li>
                <a href="/register" className="text-gray-300 hover:text-emerald-400 transition">
                  Registrarse
                </a>
              </li>
            </ul>
          </div>

          <div>
            <h4 className="text-lg font-semibold mb-4">Contacto</h4>
            <ul className="space-y-3">
              <li className="flex items-center space-x-2">
                <Mail className="w-5 h-5 text-emerald-400" />
                <span className="text-gray-300">info@zootopia.com</span>
              </li>
              <li className="flex items-center space-x-2">
                <Globe className="w-5 h-5 text-emerald-400" />
                <span className="text-gray-300">www.zootopia.com</span>
              </li>
            </ul>
          </div>
        </div>

        <div className="border-t border-gray-700 pt-6">
          <div className="flex flex-col md:flex-row justify-between items-center">
            <p className="text-gray-400 text-sm mb-4 md:mb-0">
              {currentYear} Zootopia. Todos los derechos reservados.
            </p>
            <p className="text-gray-400 text-sm flex items-center">
              Hecho con <Heart className="w-4 h-4 mx-1 text-red-500" /> para la conservación animal
            </p>
          </div>
        </div>
      </div>
    </footer>
  );
};
