import React from 'react';
import { WorldMap } from '../components/WorldMap';
import { Footprints, Leaf, Compass } from 'lucide-react';

export const Home: React.FC = () => {
  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-yellow-50 relative overflow-hidden">
      {/* Decorative Background Elements */}
      <div className="absolute inset-0 bg-pattern-leaves opacity-40"></div>

      {/* Floating Leaves */}
      <div className="absolute top-20 left-10 text-green-700/20 animate-sway">
        <Leaf className="w-24 h-24" />
      </div>
      <div className="absolute top-40 right-20 text-green-600/20 animate-float" style={{ animationDelay: '1s' }}>
        <Leaf className="w-16 h-16" />
      </div>
      <div className="absolute bottom-32 left-1/4 text-green-800/20 animate-sway" style={{ animationDelay: '2s' }}>
        <Leaf className="w-20 h-20" />
      </div>

      {/* Main Content */}
      <div className="relative flex-grow flex items-center justify-center py-12 px-4">
        <div className="w-full max-w-7xl">
          {/* Hero Section */}
          <div className="text-center mb-12">
            {/* Icon Badge */}
            <div className="inline-flex items-center justify-center mb-6">
              <div className="relative">
                <div className="absolute inset-0 bg-gradient-to-br from-orange-400 to-yellow-500 rounded-full blur-xl opacity-50 animate-pulse"></div>
                <div className="relative bg-gradient-to-br from-amber-100 to-orange-100 p-6 rounded-full shadow-2xl border-4 border-amber-300">
                  <Compass className="w-16 h-16 text-amber-800" strokeWidth={2.5} />
                </div>
              </div>
            </div>

            {/* Main Title */}
            <h1 className="text-7xl md:text-7xl font-bold text-outline-wild mb-4 leading-tight">
              Bienvenido a Zootopia
            </h1>

            {/* Paw Prints Decoration */}
            <div className="flex items-center justify-center gap-3 mb-6">
              <Footprints className="w-8 h-8 text-amber-600 rotate-12" />
              <div className="h-1 w-16 bg-gradient-to-r from-transparent via-amber-500 to-transparent"></div>
              <Footprints className="w-8 h-8 text-green-700 -rotate-12" />
            </div>

            {/* Subtitle */}
            <p className="text-2xl md:text-3xl text-gray-700 max-w-3xl mx-auto font-medium leading-relaxed">
              Explora la <span className="text-green-700 font-bold">biodiversidad salvaje</span> de nuestro zoologico.
              <br />
              Selecciona una región en el mapa para descubrir las especies que la habitan.
            </p>
          </div>

          {/* Map Container */}
          <div className="relative">
            {/* Decorative Corner Elements */}
            <div className="absolute -top-4 -left-4 w-12 h-12 border-l-4 border-t-4 border-amber-600 rounded-tl-3xl opacity-60"></div>
            <div className="absolute -top-4 -right-4 w-12 h-12 border-r-4 border-t-4 border-green-700 rounded-tr-3xl opacity-60"></div>
            <div className="absolute -bottom-4 -left-4 w-12 h-12 border-l-4 border-b-4 border-green-700 rounded-bl-3xl opacity-60"></div>
            <div className="absolute -bottom-4 -right-4 w-12 h-12 border-r-4 border-b-4 border-amber-600 rounded-br-3xl opacity-60"></div>

            {/* Map */}
            <div className="bg-white/90 backdrop-blur-sm rounded-3xl shadow-2xl p-2 md:p-4 overflow-x-auto border-4 border-amber-200 relative">
              <div className="absolute inset-0 bg-gradient-to-br from-green-50/50 to-amber-50/50 rounded-3xl pointer-events-none"></div>
              <div className="relative">
                <WorldMap />
              </div>
            </div>
          </div>

          {/* Call to Action */}
          <div className="text-center mt-10">
            <div className="inline-flex items-center gap-3 bg-gradient-to-r from-green-700 to-amber-600 text-white px-8 py-4 rounded-full shadow-xl font-bold text-lg hover:scale-105 transition-transform cursor-default">
              <Footprints className="w-6 h-6" />
              <span>Haz clic en cualquier región para explorar</span>
              <Footprints className="w-6 h-6 rotate-180" />
            </div>
          </div>

          {/* Bottom Decorative Elements */}
          <div className="flex justify-center items-center gap-4 mt-8 opacity-40">
            <div className="h-px w-20 bg-gradient-to-r from-transparent to-amber-500"></div>
            <Leaf className="w-6 h-6 text-green-700" />
            <div className="h-px w-20 bg-gradient-to-r from-amber-500 to-transparent"></div>
          </div>
        </div>
      </div>
    </div>
  );
};
