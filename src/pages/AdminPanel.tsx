import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../lib/supabase';
import { Plus, Edit, Trash2, ArrowLeft } from 'lucide-react';

interface Species {
  id: string;
  nombre_comun: string;
  nombre_cientifico: string;
  tipo: { nombre: string };
}

interface Specimen {
  id: string;
  nombre: string;
  sexo: string;
  especie: { nombre_comun: string };
}

export const AdminPanel: React.FC = () => {
  const { isAdmin, loading: authLoading } = useAuth();
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<'species' | 'specimens'>('species');
  const [especies, setEspecies] = useState<Species[]>([]);
  const [ejemplares, setEjemplares] = useState<Specimen[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!authLoading && !isAdmin()) {
      navigate('/');
    }
  }, [authLoading, isAdmin]);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      const { data: especiesData } = await supabase
        .from('especies')
        .select('id, nombre_comun, nombre_cientifico, tipo:tipos(nombre)')
        .order('nombre_comun');

      const { data: ejemplaresData } = await supabase
        .from('ejemplares')
        .select('id, nombre, sexo, especie:especies(nombre_comun)')
        .order('nombre');

      setEspecies(especiesData || []);
      setEjemplares(ejemplaresData || []);
    } catch (error) {
      console.error('Error loading data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteSpecies = async (id: string) => {
    if (!confirm('¿Estás seguro de que quieres eliminar esta especie?')) return;

    try {
      const { error } = await supabase
        .from('especies')
        .delete()
        .eq('id', id);

      if (error) throw error;
      setEspecies(especies.filter(e => e.id !== id));
    } catch (error) {
      console.error('Error deleting species:', error);
      alert('Error al eliminar la especie');
    }
  };

  const handleDeleteSpecimen = async (id: string) => {
    if (!confirm('¿Estás seguro de que quieres eliminar este ejemplar?')) return;

    try {
      const { error } = await supabase
        .from('ejemplares')
        .delete()
        .eq('id', id);

      if (error) throw error;
      setEjemplares(ejemplares.filter(e => e.id !== id));
    } catch (error) {
      console.error('Error deleting specimen:', error);
      alert('Error al eliminar el ejemplar');
    }
  };

  if (authLoading || loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-teal-50 to-cyan-50 flex items-center justify-center">
        <p className="text-gray-600 text-lg">Cargando...</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-teal-50 to-cyan-50">
      <div className="container mx-auto px-4 py-8">
        <button
          onClick={() => navigate('/')}
          className="flex items-center text-emerald-600 hover:text-emerald-700 font-semibold mb-6 transition"
        >
          <ArrowLeft className="w-5 h-5 mr-2" />
          Volver al inicio
        </button>

        <div className="bg-white rounded-3xl shadow-2xl p-8">
          <h1 className="text-4xl font-bold text-gray-800 mb-8">Panel de Administración</h1>

          <div className="flex gap-4 mb-8 border-b">
            <button
              onClick={() => setActiveTab('species')}
              className={`px-6 py-3 font-semibold transition ${
                activeTab === 'species'
                  ? 'text-emerald-600 border-b-2 border-emerald-600'
                  : 'text-gray-600 hover:text-gray-800'
              }`}
            >
              Especies
            </button>
            <button
              onClick={() => setActiveTab('specimens')}
              className={`px-6 py-3 font-semibold transition ${
                activeTab === 'specimens'
                  ? 'text-emerald-600 border-b-2 border-emerald-600'
                  : 'text-gray-600 hover:text-gray-800'
              }`}
            >
              Ejemplares
            </button>
          </div>

          {activeTab === 'species' && (
            <div>
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-2xl font-bold text-gray-800">Gestión de Especies</h2>
                <button
                  onClick={() => navigate('/admin/species/new')}
                  className="flex items-center bg-emerald-600 hover:bg-emerald-700 text-white px-6 py-3 rounded-lg font-semibold transition"
                >
                  <Plus className="w-5 h-5 mr-2" />
                  Nueva Especie
                </button>
              </div>

              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead>
                    <tr className="bg-gray-50 border-b">
                      <th className="px-6 py-4 text-left text-sm font-semibold text-gray-700">Nombre Común</th>
                      <th className="px-6 py-4 text-left text-sm font-semibold text-gray-700">Nombre Científico</th>
                      <th className="px-6 py-4 text-left text-sm font-semibold text-gray-700">Tipo</th>
                      <th className="px-6 py-4 text-right text-sm font-semibold text-gray-700">Acciones</th>
                    </tr>
                  </thead>
                  <tbody>
                    {especies.map((especie) => (
                      <tr key={especie.id} className="border-b hover:bg-gray-50 transition">
                        <td className="px-6 py-4 text-gray-800">{especie.nombre_comun}</td>
                        <td className="px-6 py-4 text-gray-600 italic">{especie.nombre_cientifico}</td>
                        <td className="px-6 py-4">
                          <span className="px-3 py-1 bg-emerald-100 text-emerald-700 rounded-full text-sm font-semibold">
                            {especie.tipo?.nombre}
                          </span>
                        </td>
                        <td className="px-6 py-4 text-right">
                          <div className="flex justify-end gap-2">
                            <button
                              onClick={() => navigate(`/admin/species/edit/${especie.id}`)}
                              className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition"
                            >
                              <Edit className="w-5 h-5" />
                            </button>
                            <button
                              onClick={() => handleDeleteSpecies(especie.id)}
                              className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition"
                            >
                              <Trash2 className="w-5 h-5" />
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {activeTab === 'specimens' && (
            <div>
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-2xl font-bold text-gray-800">Gestión de Ejemplares</h2>
                <button
                  onClick={() => navigate('/admin/specimens/new')}
                  className="flex items-center bg-emerald-600 hover:bg-emerald-700 text-white px-6 py-3 rounded-lg font-semibold transition"
                >
                  <Plus className="w-5 h-5 mr-2" />
                  Nuevo Ejemplar
                </button>
              </div>

              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead>
                    <tr className="bg-gray-50 border-b">
                      <th className="px-6 py-4 text-left text-sm font-semibold text-gray-700">Nombre</th>
                      <th className="px-6 py-4 text-left text-sm font-semibold text-gray-700">Especie</th>
                      <th className="px-6 py-4 text-left text-sm font-semibold text-gray-700">Sexo</th>
                      <th className="px-6 py-4 text-right text-sm font-semibold text-gray-700">Acciones</th>
                    </tr>
                  </thead>
                  <tbody>
                    {ejemplares.map((ejemplar) => (
                      <tr key={ejemplar.id} className="border-b hover:bg-gray-50 transition">
                        <td className="px-6 py-4 text-gray-800 font-semibold">{ejemplar.nombre}</td>
                        <td className="px-6 py-4 text-gray-600">{ejemplar.especie?.nombre_comun}</td>
                        <td className="px-6 py-4">
                          <span className={`px-3 py-1 rounded-full text-sm font-semibold ${
                            ejemplar.sexo === 'Macho' ? 'bg-blue-100 text-blue-700' : 'bg-pink-100 text-pink-700'
                          }`}>
                            {ejemplar.sexo}
                          </span>
                        </td>
                        <td className="px-6 py-4 text-right">
                          <div className="flex justify-end gap-2">
                            <button
                              onClick={() => navigate(`/admin/specimens/edit/${ejemplar.id}`)}
                              className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition"
                            >
                              <Edit className="w-5 h-5" />
                            </button>
                            <button
                              onClick={() => handleDeleteSpecimen(ejemplar.id)}
                              className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition"
                            >
                              <Trash2 className="w-5 h-5" />
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
