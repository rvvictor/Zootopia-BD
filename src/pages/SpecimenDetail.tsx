import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { ArrowLeft, Calendar, MapPin, Heart, FileText, Activity } from 'lucide-react';

interface SpecimenDetail {
  id: string;
  nombre: string;
  sexo: 'Macho' | 'Hembra';
  fecha_nacimiento: string | null;
  fecha_ingreso: string;
  habitat_actual: string | null;
  estado_salud: string;
  observaciones: string | null;
  imagen_url: string | null;
  especie: {
    nombre_comun: string;
    nombre_cientifico: string;
  };
}

export const SpecimenDetail: React.FC = () => {
  const { specimenId } = useParams();
  const navigate = useNavigate();
  const [specimen, setSpecimen] = useState<SpecimenDetail | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadData();
  }, [specimenId]);

  const loadData = async () => {
    try {
      const { data, error } = await supabase
        .from('ejemplares')
        .select(`
          id,
          nombre,
          sexo,
          fecha_nacimiento,
          fecha_ingreso,
          habitat_actual,
          estado_salud,
          observaciones,
          imagen_url,
          especie:especies(nombre_comun, nombre_cientifico)
        `)
        .eq('id', specimenId)
        .maybeSingle();

      if (error) throw error;
      setSpecimen(data);
    } catch (error) {
      console.error('Error loading specimen:', error);
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString: string | null): string => {
    if (!dateString) return 'No disponible';
    const date = new Date(dateString);
    return date.toLocaleDateString('es-ES', { year: 'numeric', month: 'long', day: 'numeric' });
  };

  const calculateAge = (birthDate: string | null): string => {
    if (!birthDate) return 'Desconocida';
    const birth = new Date(birthDate);
    const today = new Date();
    const years = today.getFullYear() - birth.getFullYear();
    const months = today.getMonth() - birth.getMonth();

    if (years === 0) {
      return `${months} ${months === 1 ? 'mes' : 'meses'}`;
    }

    return `${years} ${years === 1 ? 'año' : 'años'}`;
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-teal-50 to-cyan-50 flex items-center justify-center">
        <p className="text-gray-600 text-lg">Cargando información...</p>
      </div>
    );
  }

  if (!specimen) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-teal-50 to-cyan-50 flex items-center justify-center">
        <p className="text-gray-600 text-lg">Ejemplar no encontrado</p>
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

        <div className="bg-white rounded-3xl shadow-2xl overflow-hidden">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 p-8">
            <div>
              <div className="aspect-square bg-gradient-to-br from-emerald-100 to-teal-100 rounded-2xl overflow-hidden mb-6">
                {specimen.imagen_url ? (
                  <img
                    src={specimen.imagen_url}
                    alt={specimen.nombre}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center text-gray-400 text-2xl">
                    Sin imagen disponible
                  </div>
                )}
              </div>

              <div className="bg-gradient-to-br from-gray-50 to-gray-100 rounded-2xl p-6">
                <h3 className="text-lg font-bold text-gray-800 mb-3">Información de la Especie</h3>
                <p className="text-xl font-semibold text-gray-800">{specimen.especie?.nombre_comun}</p>
                <p className="text-gray-600 italic">{specimen.especie?.nombre_cientifico}</p>
              </div>
            </div>

            <div>
              <div className="mb-6">
                <h1 className="text-4xl font-bold text-gray-800 mb-2">{specimen.nombre}</h1>
                <div className="flex gap-3 mb-4">
                  <span className={`px-4 py-2 rounded-full font-semibold ${specimen.sexo === 'Macho' ? 'bg-blue-100 text-blue-700' : 'bg-pink-100 text-pink-700'
                    }`}>
                    {specimen.sexo}
                  </span>
                  <span className={`px-4 py-2 rounded-full font-semibold ${specimen.estado_salud === 'Saludable' ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700'
                    }`}>
                    {specimen.estado_salud}
                  </span>
                </div>
              </div>

              <div className="space-y-4">
                <div className="p-5 bg-gradient-to-br from-blue-50 to-cyan-50 rounded-2xl">
                  <div className="flex items-center mb-2">
                    <Calendar className="w-5 h-5 text-blue-600 mr-2" />
                    <h3 className="text-lg font-bold text-gray-800">Fecha de Nacimiento</h3>
                  </div>
                  <p className="text-gray-700">{formatDate(specimen.fecha_nacimiento)}</p>
                  <p className="text-sm text-gray-600 mt-1">Edad: {calculateAge(specimen.fecha_nacimiento)}</p>
                </div>

                <div className="p-5 bg-gradient-to-br from-green-50 to-emerald-50 rounded-2xl">
                  <div className="flex items-center mb-2">
                    <Calendar className="w-5 h-5 text-green-600 mr-2" />
                    <h3 className="text-lg font-bold text-gray-800">Fecha de Ingreso</h3>
                  </div>
                  <p className="text-gray-700">{formatDate(specimen.fecha_ingreso)}</p>
                </div>

                <div className="p-5 bg-gradient-to-br from-teal-50 to-cyan-50 rounded-2xl">
                  <div className="flex items-center mb-2">
                    <MapPin className="w-5 h-5 text-teal-600 mr-2" />
                    <h3 className="text-lg font-bold text-gray-800">Hábitat Actual</h3>
                  </div>
                  <p className="text-gray-700">{specimen.habitat_actual || 'No especificado'}</p>
                </div>

                <div className="p-5 bg-gradient-to-br from-orange-50 to-amber-50 rounded-2xl">
                  <div className="flex items-center mb-2">
                    <Heart className="w-5 h-5 text-orange-600 mr-2" />
                    <h3 className="text-lg font-bold text-gray-800">Estado de Salud</h3>
                  </div>
                  <p className="text-gray-700">{specimen.estado_salud}</p>
                </div>

                {specimen.observaciones && (
                  <div className="p-5 bg-gradient-to-br from-purple-50 to-pink-50 rounded-2xl">
                    <div className="flex items-center mb-2">
                      <FileText className="w-5 h-5 text-purple-600 mr-2" />
                      <h3 className="text-lg font-bold text-gray-800">Observaciones</h3>
                    </div>
                    <p className="text-gray-700 leading-relaxed">{specimen.observaciones}</p>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
