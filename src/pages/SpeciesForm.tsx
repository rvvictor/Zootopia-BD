import React, { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../lib/supabase';
import { ArrowLeft, Save } from 'lucide-react';

interface FormData {
  nombre_comun: string;
  nombre_cientifico: string;
  tipo_id: string;
  pais_id: string;
  ecosistema_id: string;
  habitat_natural: string;
  dieta: string;
  reproduccion: string;
  longevidad: string;
  comportamiento: string;
  estado_conservacion_id: string;
  descripcion_general: string;
  imagen_url: string;
  modelo_3d_url: string;
}

export const SpeciesForm: React.FC = () => {
  const { speciesId } = useParams();
  const navigate = useNavigate();
  const { isAdmin, loading: authLoading } = useAuth();
  const [loading, setLoading] = useState(false);
  const [tipos, setTipos] = useState<any[]>([]);
  const [paises, setPaises] = useState<any[]>([]);
  const [ecosistemas, setEcosistemas] = useState<any[]>([]);
  const [estadosConservacion, setEstadosConservacion] = useState<any[]>([]);
  const [formData, setFormData] = useState<FormData>({
    nombre_comun: '',
    nombre_cientifico: '',
    tipo_id: '',
    pais_id: '',
    ecosistema_id: '',
    habitat_natural: '',
    dieta: '',
    reproduccion: '',
    longevidad: '',
    comportamiento: '',
    estado_conservacion_id: '',
    descripcion_general: '',
    imagen_url: '',
    modelo_3d_url: '',
  });

  useEffect(() => {
    if (!authLoading && !isAdmin()) {
      navigate('/');
    }
  }, [authLoading, isAdmin]);

  useEffect(() => {
    loadOptions();
    if (speciesId) {
      loadSpecies();
    }
  }, [speciesId]);

  const loadOptions = async () => {
    const [tiposRes, paisesRes, ecosistemasRes, estadosRes] = await Promise.all([
      supabase.from('tipos').select('*').order('nombre'),
      supabase.from('paises').select('*').order('nombre'),
      supabase.from('ecosistemas').select('*').order('nombre'),
      supabase.from('estados_conservacion').select('*').order('nombre'),
    ]);

    setTipos(tiposRes.data || []);
    setPaises(paisesRes.data || []);
    setEcosistemas(ecosistemasRes.data || []);
    setEstadosConservacion(estadosRes.data || []);
  };

  const loadSpecies = async () => {
    try {
      const { data, error } = await supabase
        .from('especies')
        .select('*')
        .eq('id', speciesId)
        .maybeSingle();

      if (error) throw error;
      if (data) {
        setFormData({
          nombre_comun: data.nombre_comun || '',
          nombre_cientifico: data.nombre_cientifico || '',
          tipo_id: data.tipo_id || '',
          pais_id: data.pais_id || '',
          ecosistema_id: data.ecosistema_id || '',
          habitat_natural: data.habitat_natural || '',
          dieta: data.dieta || '',
          reproduccion: data.reproduccion || '',
          longevidad: data.longevidad || '',
          comportamiento: data.comportamiento || '',
          estado_conservacion_id: data.estado_conservacion_id || '',
          descripcion_general: data.descripcion_general || '',
          imagen_url: data.imagen_url || '',
          modelo_3d_url: data.modelo_3d_url || '',
        });
      }
    } catch (error) {
      console.error('Error loading species:', error);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (speciesId) {
        const { error } = await supabase
          .from('especies')
          .update(formData)
          .eq('id', speciesId);

        if (error) throw error;
      } else {
        const { error } = await supabase
          .from('especies')
          .insert([formData]);

        if (error) throw error;
      }

      navigate('/admin');
    } catch (error) {
      console.error('Error saving species:', error);
      alert('Error al guardar la especie');
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-teal-50 to-cyan-50">
      <div className="container mx-auto px-4 py-8">
        <button
          onClick={() => navigate('/admin')}
          className="flex items-center text-emerald-600 hover:text-emerald-700 font-semibold mb-6 transition"
        >
          <ArrowLeft className="w-5 h-5 mr-2" />
          Volver al panel
        </button>

        <div className="bg-white rounded-3xl shadow-2xl p-8 max-w-4xl mx-auto">
          <h1 className="text-4xl font-bold text-gray-800 mb-8">
            {speciesId ? 'Editar Especie' : 'Nueva Especie'}
          </h1>

          <form onSubmit={handleSubmit} className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Nombre Común *
                </label>
                <input
                  type="text"
                  name="nombre_comun"
                  value={formData.nombre_comun}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Nombre Científico *
                </label>
                <input
                  type="text"
                  name="nombre_cientifico"
                  value={formData.nombre_cientifico}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Tipo *</label>
                <select
                  name="tipo_id"
                  value={formData.tipo_id}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                >
                  <option value="">Seleccionar tipo</option>
                  {tipos.map((tipo) => (
                    <option key={tipo.id} value={tipo.id}>{tipo.nombre}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">País *</label>
                <select
                  name="pais_id"
                  value={formData.pais_id}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                >
                  <option value="">Seleccionar país</option>
                  {paises.map((pais) => (
                    <option key={pais.id} value={pais.id}>{pais.nombre}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Ecosistema *</label>
                <select
                  name="ecosistema_id"
                  value={formData.ecosistema_id}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                >
                  <option value="">Seleccionar ecosistema</option>
                  {ecosistemas.map((eco) => (
                    <option key={eco.id} value={eco.id}>{eco.nombre}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Estado de Conservación *</label>
                <select
                  name="estado_conservacion_id"
                  value={formData.estado_conservacion_id}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                >
                  <option value="">Seleccionar estado</option>
                  {estadosConservacion.map((estado) => (
                    <option key={estado.id} value={estado.id}>{estado.nombre}</option>
                  ))}
                </select>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">URL de Imagen</label>
              <input
                type="url"
                name="imagen_url"
                value={formData.imagen_url}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                placeholder="https://example.com/image.jpg"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">URL de Modelo 3D</label>
              <input
                type="url"
                name="modelo_3d_url"
                value={formData.modelo_3d_url}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                placeholder="https://example.com/model.glb"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Descripción General</label>
              <textarea
                name="descripcion_general"
                value={formData.descripcion_general}
                onChange={handleChange}
                rows={4}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Hábitat Natural</label>
              <textarea
                name="habitat_natural"
                value={formData.habitat_natural}
                onChange={handleChange}
                rows={3}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Dieta</label>
              <textarea
                name="dieta"
                value={formData.dieta}
                onChange={handleChange}
                rows={3}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Reproducción</label>
              <textarea
                name="reproduccion"
                value={formData.reproduccion}
                onChange={handleChange}
                rows={3}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Longevidad</label>
              <input
                type="text"
                name="longevidad"
                value={formData.longevidad}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                placeholder="Ej: 15-20 años"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Comportamiento</label>
              <textarea
                name="comportamiento"
                value={formData.comportamiento}
                onChange={handleChange}
                rows={3}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>

            <div className="flex gap-4">
              <button
                type="submit"
                disabled={loading}
                className="flex-1 flex items-center justify-center bg-emerald-600 hover:bg-emerald-700 text-white px-6 py-3 rounded-lg font-semibold transition disabled:opacity-50"
              >
                <Save className="w-5 h-5 mr-2" />
                {loading ? 'Guardando...' : 'Guardar Especie'}
              </button>
              <button
                type="button"
                onClick={() => navigate('/admin')}
                className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg font-semibold hover:bg-gray-50 transition"
              >
                Cancelar
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};
