import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { ArrowLeft, MapPin, Leaf, Heart, Calendar, Activity, AlertTriangle } from 'lucide-react';
import { Model3DViewer } from '../components/Model3DViewer';

interface SpeciesDetail {
  id: string;
  nombre_comun: string;
  nombre_cientifico: string;
  imagen_url: string | null;
  modelo_3d_url: string | null;
  habitat_natural: string;
  dieta: string;
  reproduccion: string;
  longevidad: string;
  comportamiento: string;
  descripcion_general: string;
  tipo: { nombre: string };
  pais: { nombre: string; region: { nombre: string } };
  ecosistema: { nombre: string };
  estado_conservacion: { nombre: string; codigo: string };
}

interface Specimen {
  id: string;
  nombre: string;
  sexo: string;
  imagen_url: string | null;
  estado_salud: string;
}

export const SpeciesDetail: React.FC = () => {
  const { speciesId } = useParams();
  const navigate = useNavigate();
  const [species, setSpecies] = useState<SpeciesDetail | null>(null);
  const [specimens, setSpecimens] = useState<Specimen[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadData();
  }, [speciesId]);

  const loadData = async () => {
    try {
      const { data: speciesData, error: speciesError } = await supabase
        .from('especies')
        .select(`
          id,
          nombre_comun,
          nombre_cientifico,
          imagen_url,
          modelo_3d_url,
          habitat_natural,
          dieta,
          reproduccion,
          longevidad,
          comportamiento,
          descripcion_general,
          tipo:tipos(nombre),
          pais:paises(nombre, region:regiones(nombre)),
          ecosistema:ecosistemas(nombre),
          estado_conservacion:estados_conservacion(nombre, codigo)
        `)
        .eq('id', speciesId)
        .maybeSingle();

      if (speciesError) throw speciesError;
      setSpecies(speciesData);

      const { data: specimensData, error: specimensError } = await supabase
        .from('ejemplares')
        .select('id, nombre, sexo, imagen_url, estado_salud')
        .eq('especie_id', speciesId);

      if (specimensError) throw specimensError;
      setSpecimens(specimensData || []);
    } catch (error) {
      console.error('Error loading data:', error);
    } finally {
      setLoading(false);
    }
  };

  const getConservationColor = (codigo: string): string => {
    const colors: { [key: string]: string } = {
      'CR': 'bg-red-600',
      'EN': 'bg-orange-600',
      'VU': 'bg-yellow-600',
      'NT': 'bg-blue-600',
      'LC': 'bg-green-600',
    };
    return colors[codigo] || 'bg-gray-600';
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-teal-50 to-cyan-50 flex items-center justify-center">
        <p className="text-gray-600 text-lg">Cargando información...</p>
      </div>
    );
  }

  if (!species) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-teal-50 to-cyan-50 flex items-center justify-center">
        <p className="text-gray-600 text-lg">Especie no encontrada</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-teal-50 to-cyan-50">
      <div className="container mx-auto px-4 py-8">
        <button
          onClick={() => navigate(-1)}
          className="flex items-center text-emerald-600 hover:text-emerald-700 font-semibold mb-6 transition"
        >
          <ArrowLeft className="w-5 h-5 mr-2" />
          Volver
        </button>

        <div className="bg-white rounded-3xl shadow-2xl overflow-hidden mb-8">
          <div className="min-h-[400px] md:min-h-[500px] bg-gradient-to-br from-emerald-100 to-teal-100 relative">
            <Model3DViewer
              modelUrl={species.modelo_3d_url}
              fallbackImageUrl={species.imagen_url}
              altText={species.nombre_comun}
            />
            <div className={`absolute top-6 right-6 ${getConservationColor(species.estado_conservacion?.codigo || '')} text-white px-6 py-3 rounded-full font-semibold shadow-lg z-10`}>
              {species.estado_conservacion?.nombre}
            </div>
          </div>

          <div className="p-8">
            <div className="mb-6">
              <h1 className="text-4xl font-bold text-gray-800 mb-2">
                {species.nombre_comun}
              </h1>
              <p className="text-xl text-gray-500 italic mb-4">
                {species.nombre_cientifico}
              </p>
              <div className="flex flex-wrap gap-3">
                <span className="px-4 py-2 bg-emerald-100 text-emerald-700 rounded-full font-semibold">
                  {species.tipo?.nombre}
                </span>
                <span className="px-4 py-2 bg-blue-100 text-blue-700 rounded-full font-semibold flex items-center">
                  <MapPin className="w-4 h-4 mr-2" />
                  {species.pais?.nombre}
                </span>
                <span className="px-4 py-2 bg-teal-100 text-teal-700 rounded-full font-semibold flex items-center">
                  <Leaf className="w-4 h-4 mr-2" />
                  {species.ecosistema?.nombre}
                </span>
              </div>
            </div>

            {species.descripcion_general && (
              <div className="mb-8 p-6 bg-gray-50 rounded-2xl">
                <h2 className="text-2xl font-bold text-gray-800 mb-3">Descripción General</h2>
                <p className="text-gray-700 leading-relaxed">{species.descripcion_general}</p>
              </div>
            )}

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
              <div className="p-6 bg-gradient-to-br from-green-50 to-emerald-50 rounded-2xl">
                <h3 className="text-xl font-bold text-gray-800 mb-3 flex items-center">
                  <Leaf className="w-6 h-6 mr-2 text-green-600" />
                  Hábitat Natural
                </h3>
                <p className="text-gray-700">{species.habitat_natural || 'No disponible'}</p>
              </div>

              <div className="p-6 bg-gradient-to-br from-orange-50 to-amber-50 rounded-2xl">
                <h3 className="text-xl font-bold text-gray-800 mb-3 flex items-center">
                  <Activity className="w-6 h-6 mr-2 text-orange-600" />
                  Dieta
                </h3>
                <p className="text-gray-700">{species.dieta || 'No disponible'}</p>
              </div>

              <div className="p-6 bg-gradient-to-br from-pink-50 to-rose-50 rounded-2xl">
                <h3 className="text-xl font-bold text-gray-800 mb-3 flex items-center">
                  <Heart className="w-6 h-6 mr-2 text-pink-600" />
                  Reproducción
                </h3>
                <p className="text-gray-700">{species.reproduccion || 'No disponible'}</p>
              </div>

              <div className="p-6 bg-gradient-to-br from-blue-50 to-cyan-50 rounded-2xl">
                <h3 className="text-xl font-bold text-gray-800 mb-3 flex items-center">
                  <Calendar className="w-6 h-6 mr-2 text-blue-600" />
                  Longevidad
                </h3>
                <p className="text-gray-700">{species.longevidad || 'No disponible'}</p>
              </div>
            </div>

            {species.comportamiento && (
              <div className="mb-8 p-6 bg-gradient-to-br from-purple-50 to-pink-50 rounded-2xl">
                <h3 className="text-xl font-bold text-gray-800 mb-3">Comportamiento</h3>
                <p className="text-gray-700">{species.comportamiento}</p>
              </div>
            )}

            {species.estado_conservacion?.codigo !== 'LC' && (
              <div className="mb-8 p-6 bg-gradient-to-br from-red-50 to-orange-50 rounded-2xl border-2 border-red-200">
                <h3 className="text-xl font-bold text-red-700 mb-3 flex items-center">
                  <AlertTriangle className="w-6 h-6 mr-2" />
                  Estado de Conservación
                </h3>
                <p className="text-gray-700">
                  Esta especie se encuentra en estado: <strong>{species.estado_conservacion?.nombre}</strong>
                </p>
              </div>
            )}
          </div>
        </div>

        <div className="bg-white rounded-3xl shadow-2xl p-8">
          <h2 className="text-3xl font-bold text-gray-800 mb-6">
            Ejemplares en el Zoológico ({specimens.length})
          </h2>

          {specimens.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {specimens.map((specimen) => (
                <button
                  key={specimen.id}
                  onClick={() => navigate(`/specimen/${specimen.id}`)}
                  className="bg-gradient-to-br from-gray-50 to-gray-100 rounded-2xl p-6 hover:shadow-lg transition-all duration-300 text-left transform hover:-translate-y-1"
                >
                  <div className="aspect-square bg-gradient-to-br from-emerald-100 to-teal-100 rounded-xl mb-4 overflow-hidden">
                    {specimen.imagen_url ? (
                      <img
                        src={specimen.imagen_url}
                        alt={specimen.nombre}
                        className="w-full h-full object-cover"
                      />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center text-gray-400">
                        Sin imagen
                      </div>
                    )}
                  </div>
                  <h3 className="text-xl font-bold text-gray-800 mb-2">{specimen.nombre}</h3>
                  <div className="flex items-center justify-between">
                    <span className="text-gray-600">{specimen.sexo}</span>
                    <span className={`px-3 py-1 rounded-full text-xs font-semibold ${specimen.estado_salud === 'Saludable' ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700'
                      }`}>
                      {specimen.estado_salud}
                    </span>
                  </div>
                </button>
              ))}
            </div>
          ) : (
            <p className="text-gray-600 text-center py-8">
              No hay ejemplares registrados de esta especie
            </p>
          )}
        </div>
      </div>
    </div>
  );
};
