import React, { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../lib/supabase';
import { ArrowLeft, Save } from 'lucide-react';

interface FormData {
  nombre: string;
  especie_id: string;
  sexo: 'Macho' | 'Hembra' | '';
  fecha_nacimiento: string;
  fecha_ingreso: string;
  habitat_actual: string;
  estado_salud: string;
  observaciones: string;
  imagen_url: string;
}

export const SpecimenForm: React.FC = () => {
  const { specimenId } = useParams();
  const navigate = useNavigate();
  const { isAdmin, loading: authLoading } = useAuth();
  const [loading, setLoading] = useState(false);
  const [especies, setEspecies] = useState<any[]>([]);
  const [formData, setFormData] = useState<FormData>({
    nombre: '',
    especie_id: '',
    sexo: '',
    fecha_nacimiento: '',
    fecha_ingreso: new Date().toISOString().split('T')[0],
    habitat_actual: '',
    estado_salud: 'Saludable',
    observaciones: '',
    imagen_url: '',
  });

  useEffect(() => {
    if (!authLoading && !isAdmin()) {
      navigate('/');
    }
  }, [authLoading, isAdmin]);

  useEffect(() => {
    loadEspecies();
    if (specimenId) {
      loadSpecimen();
    }
  }, [specimenId]);

  const loadEspecies = async () => {
    const { data } = await supabase
      .from('especies')
      .select('id, nombre_comun')
      .order('nombre_comun');

    setEspecies(data || []);
  };

  const loadSpecimen = async () => {
    try {
      const { data, error } = await supabase
        .from('ejemplares')
        .select('*')
        .eq('id', specimenId)
        .maybeSingle();

      if (error) throw error;
      if (data) {
        setFormData({
          nombre: data.nombre || '',
          especie_id: data.especie_id || '',
          sexo: data.sexo === 'M' ? 'Macho' : data.sexo === 'F' ? 'Hembra' : '',
          fecha_nacimiento: data.fecha_nacimiento || '',
          fecha_ingreso: data.fecha_ingreso || '',
          habitat_actual: data.habitat_actual || '',
          estado_salud: data.estado_salud || 'Saludable',
          observaciones: data.observaciones || '',
          imagen_url: data.imagen_url || '',
        });
      }
    } catch (error) {
      console.error('Error loading specimen:', error);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      // Convertir sexo de "Macho"/"Hembra" a "M"/"F"
      const dataToSave = {
        ...formData,
        sexo: formData.sexo === 'Macho' ? 'M' : formData.sexo === 'Hembra' ? 'F' : formData.sexo
      };

      if (specimenId) {
        const { error } = await supabase
          .from('ejemplares')
          .update(dataToSave)
          .eq('id', specimenId);

        if (error) throw error;
      } else {
        const { error } = await supabase
          .from('ejemplares')
          .insert([dataToSave]);

        if (error) throw error;
      }

      navigate('/admin');
    } catch (error) {
      console.error('Error saving specimen:', error);
      alert('Error al guardar el ejemplar');
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
            {specimenId ? 'Editar Ejemplar' : 'Nuevo Ejemplar'}
          </h1>

          <form onSubmit={handleSubmit} className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Nombre *
                </label>
                <input
                  type="text"
                  name="nombre"
                  value={formData.nombre}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Especie *</label>
                <select
                  name="especie_id"
                  value={formData.especie_id}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                >
                  <option value="">Seleccionar especie</option>
                  {especies.map((especie) => (
                    <option key={especie.id} value={especie.id}>
                      {especie.nombre_comun}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Sexo *</label>
                <select
                  name="sexo"
                  value={formData.sexo}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                >
                  <option value="">Seleccionar sexo</option>
                  <option value="Macho">Macho</option>
                  <option value="Hembra">Hembra</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Fecha de Nacimiento
                </label>
                <input
                  type="date"
                  name="fecha_nacimiento"
                  value={formData.fecha_nacimiento}
                  onChange={handleChange}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Fecha de Ingreso *
                </label>
                <input
                  type="date"
                  name="fecha_ingreso"
                  value={formData.fecha_ingreso}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Estado de Salud
                </label>
                <input
                  type="text"
                  name="estado_salud"
                  value={formData.estado_salud}
                  onChange={handleChange}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Hábitat Actual</label>
              <input
                type="text"
                name="habitat_actual"
                value={formData.habitat_actual}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                placeholder="Ej: Zona de Sabana Africana"
              />
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
              <label className="block text-sm font-medium text-gray-700 mb-2">Observaciones</label>
              <textarea
                name="observaciones"
                value={formData.observaciones}
                onChange={handleChange}
                rows={4}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                placeholder="Notas sobre comportamiento, salud, o cualquier otra información relevante..."
              />
            </div>

            <div className="flex gap-4">
              <button
                type="submit"
                disabled={loading}
                className="flex-1 flex items-center justify-center bg-emerald-600 hover:bg-emerald-700 text-white px-6 py-3 rounded-lg font-semibold transition disabled:opacity-50"
              >
                <Save className="w-5 h-5 mr-2" />
                {loading ? 'Guardando...' : 'Guardar Ejemplar'}
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
