import React from 'react';
import { WorldMap } from '../components/WorldMap';
import { Globe } from 'lucide-react';

export const Home: React.FC = () => {
  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-teal-50 to-cyan-50 flex flex-col">
      <div className="flex-grow flex items-center justify-center py-12 px-4">
        <div className="w-full max-w-7xl">
          <div className="text-center mb-12">
            <div className="inline-block bg-white p-4 rounded-full shadow-lg mb-6">
              <Globe className="w-16 h-16 text-emerald-600" />
            </div>
            <h1 className="text-6xl font-bold text-gray-800 mb-4">
              Bienvenido a Zootopia
            </h1>
            <p className="text-2xl text-gray-600 max-w-3xl mx-auto">
              Explora la biodiversidad del mundo. Selecciona una región en el mapa para descubrir las especies que la habitan.
            </p>
          </div>

          <div className="bg-white rounded-3xl shadow-2xl p-8">
            <WorldMap />
          </div>

          <div className="text-center mt-8">
            <p className="text-gray-600 text-lg">
              Haz clic en cualquier región para explorar
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};
