import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { ArrowLeft, Filter, Search } from 'lucide-react';

interface Species {
  id: string;
  nombre_comun: string;
  nombre_cientifico: string;
  imagen_url: string | null;
  tipo: { nombre: string };
  pais: { nombre: string };
  ecosistema: { nombre: string };
  estado_conservacion: { nombre: string; codigo: string };
}

interface FilterOptions {
  tipos: { id: string; nombre: string }[];
  paises: { id: string; nombre: string }[];
  ecosistemas: { id: string; nombre: string }[];
}

export const RegionSpecies: React.FC = () => {
  const { regionId } = useParams();
  const navigate = useNavigate();
  const [especies, setEspecies] = useState<Species[]>([]);
  const [filteredEspecies, setFilteredEspecies] = useState<Species[]>([]);
  const [filterOptions, setFilterOptions] = useState<FilterOptions>({
    tipos: [],
    paises: [],
    ecosistemas: [],
  });
  const [selectedTipo, setSelectedTipo] = useState('');
  const [selectedPais, setSelectedPais] = useState('');
  const [selectedEcosistema, setSelectedEcosistema] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(true);
  const [regionName, setRegionName] = useState('');

  useEffect(() => {
    loadData();
  }, [regionId]);

  useEffect(() => {
    applyFilters();
  }, [especies, selectedTipo, selectedPais, selectedEcosistema, searchTerm]);

  const loadData = async () => {
    try {
      const { data: regionData } = await supabase
        .from('regiones')
        .select('nombre')
        .eq('id', regionId)
        .maybeSingle();

      if (regionData) {
        setRegionName(regionData.nombre);
      }

      const { data: paisesData } = await supabase
        .from('paises')
        .select('id, nombre')
        .eq('region_id', regionId);

      const paisIds = paisesData?.map(p => p.id) || [];

      const { data: especiesData, error } = await supabase
        .from('especies')
        .select(`
          id,
          nombre_comun,
          nombre_cientifico,
          imagen_url,
          tipo:tipos(nombre),
          pais:paises(nombre),
          ecosistema:ecosistemas(nombre),
          estado_conservacion:estados_conservacion(nombre, codigo)
        `)
        .in('pais_id', paisIds);

      if (error) throw error;

      // Transform the data to match the Species interface
      const transformedData = especiesData?.map((especie: any) => ({
        id: especie.id,
        nombre_comun: especie.nombre_comun,
        nombre_cientifico: especie.nombre_cientifico,
        imagen_url: especie.imagen_url,
        tipo: Array.isArray(especie.tipo) ? especie.tipo[0] : especie.tipo,
        pais: Array.isArray(especie.pais) ? especie.pais[0] : especie.pais,
        ecosistema: Array.isArray(especie.ecosistema) ? especie.ecosistema[0] : especie.ecosistema,
        estado_conservacion: Array.isArray(especie.estado_conservacion)
          ? especie.estado_conservacion[0]
          : especie.estado_conservacion,
      })) || [];

      setEspecies(transformedData);

      // Filtrar países para mostrar solo los que tienen especies
      const paisesConEspecies = paisesData?.filter(pais =>
        transformedData.some(especie => especie.pais?.nombre === pais.nombre)
      ) || [];

      const { data: tiposData } = await supabase
        .from('tipos')
        .select('id, nombre')
        .order('nombre');

      const { data: ecosistemasData } = await supabase
        .from('ecosistemas')
        .select('id, nombre')
        .order('nombre');

      setFilterOptions({
        tipos: tiposData || [],
        paises: paisesConEspecies,
        ecosistemas: ecosistemasData || [],
      });
    } catch (error) {
      console.error('Error loading data:', error);
    } finally {
      setLoading(false);
    }
  };

  const applyFilters = () => {
    let filtered = [...especies];

    if (selectedTipo) {
      filtered = filtered.filter(e => e.tipo?.nombre === selectedTipo);
    }

    if (selectedPais) {
      filtered = filtered.filter(e => e.pais?.nombre === selectedPais);
    }

    if (selectedEcosistema) {
      filtered = filtered.filter(e => e.ecosistema?.nombre === selectedEcosistema);
    }

    if (searchTerm) {
      filtered = filtered.filter(e =>
        e.nombre_comun.toLowerCase().includes(searchTerm.toLowerCase()) ||
        e.nombre_cientifico.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    setFilteredEspecies(filtered);
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
        <p className="text-gray-600 text-lg">Cargando especies...</p>
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
          Volver al mapa
        </button>

        <div className="bg-white rounded-3xl shadow-2xl p-8 mb-8">
          <h1 className="text-4xl font-bold text-gray-800 mb-2">
            Especies de {regionName}
          </h1>
          <p className="text-gray-600 mb-6">
            {filteredEspecies.length} especies encontradas
          </p>

          <div className="mb-6">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
              <input
                type="text"
                placeholder="Buscar por nombre..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                <Filter className="w-4 h-4 mr-2" />
                Tipo de Animal
              </label>
              <select
                value={selectedTipo}
                onChange={(e) => setSelectedTipo(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              >
                <option value="">Todos los tipos</option>
                {filterOptions.tipos.map((tipo) => (
                  <option key={tipo.id} value={tipo.nombre}>
                    {tipo.nombre}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                <Filter className="w-4 h-4 mr-2" />
                País
              </label>
              <select
                value={selectedPais}
                onChange={(e) => setSelectedPais(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              >
                <option value="">Todos los países</option>
                {filterOptions.paises.map((pais) => (
                  <option key={pais.id} value={pais.nombre}>
                    {pais.nombre}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                <Filter className="w-4 h-4 mr-2" />
                Ecosistema
              </label>
              <select
                value={selectedEcosistema}
                onChange={(e) => setSelectedEcosistema(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              >
                <option value="">Todos los ecosistemas</option>
                {filterOptions.ecosistemas.map((eco) => (
                  <option key={eco.id} value={eco.nombre}>
                    {eco.nombre}
                  </option>
                ))}
              </select>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredEspecies.map((especie) => (
            <button
              key={especie.id}
              onClick={() => navigate(`/species/${especie.id}`)}
              className="bg-white rounded-2xl shadow-lg hover:shadow-2xl transition-all duration-300 overflow-hidden group transform hover:-translate-y-1"
            >
              <div className="aspect-video bg-gradient-to-br from-emerald-100 to-teal-100 relative overflow-hidden">
                {especie.imagen_url ? (
                  <img
                    src={especie.imagen_url}
                    alt={especie.nombre_comun}
                    className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-300"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center text-gray-400">
                    Sin imagen
                  </div>
                )}
                <div className={`absolute top-3 right-3 ${getConservationColor(especie.estado_conservacion?.codigo || '')} text-white px-3 py-1 rounded-full text-xs font-semibold`}>
                  {especie.estado_conservacion?.codigo}
                </div>
              </div>
              <div className="p-5">
                <h3 className="text-xl font-bold text-gray-800 mb-1">
                  {especie.nombre_comun}
                </h3>
                <p className="text-sm text-gray-500 italic mb-3">
                  {especie.nombre_cientifico}
                </p>
                <div className="flex flex-wrap gap-2">
                  <span className="px-3 py-1 bg-emerald-100 text-emerald-700 rounded-full text-xs font-semibold">
                    {especie.tipo?.nombre}
                  </span>
                  <span className="px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-semibold">
                    {especie.ecosistema?.nombre}
                  </span>
                </div>
              </div>
            </button>
          ))}
        </div>

        {filteredEspecies.length === 0 && (
          <div className="text-center py-12">
            <p className="text-gray-600 text-lg">
              No se encontraron especies con los filtros seleccionados
            </p>
          </div>
        )}
      </div>
    </div>
  );
};
