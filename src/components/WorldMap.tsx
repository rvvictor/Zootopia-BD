import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import {
  ComposableMap,
  Geographies,
  Geography,
} from 'react-simple-maps';
import { Tooltip } from 'react-tooltip';

interface Region {
  id: string;
  nombre: string;
}

interface CountryWithSpecies {
  countryName: string;
  regionName: string;
  hasSpecies: boolean;
}

// Mapa de continentes a nombres de regiones en la base de datos
const continentToRegion: Record<string, string> = {
  'North America': 'América del Norte',
  'South America': 'América del Sur',
  'Europe': 'Europa',
  'Africa': 'África',
  'Asia': 'Asia',
  'Oceania': 'Australia',
};

// Mapeo de nombres de países en inglés (TopoJSON) a español (Base de datos)
const countryNameMap: Record<string, string> = {
  // África
  'Algeria': 'Argelia',
  'Angola': 'Angola',
  'Benin': 'Benín',
  'Botswana': 'Botsuana',
  'Burkina Faso': 'Burkina Faso',
  'Burundi': 'Burundi',
  'Cameroon': 'Camerún',
  'Cape Verde': 'Cabo Verde',
  'Central African Republic': 'República Centroafricana',
  'Chad': 'Chad',
  'Comoros': 'Comoras',
  'Democratic Republic of the Congo': 'República Democrática del Congo',
  'Republic of the Congo': 'República del Congo',
  'Djibouti': 'Yibuti',
  'Egypt': 'Egipto',
  'Equatorial Guinea': 'Guinea Ecuatorial',
  'Eritrea': 'Eritrea',
  'Ethiopia': 'Etiopía',
  'Gabon': 'Gabón',
  'Gambia': 'Gambia',
  'Ghana': 'Ghana',
  'Guinea': 'Guinea',
  'Guinea-Bissau': 'Guinea-Bisáu',
  'Ivory Coast': 'Costa de Marfil',
  'Kenya': 'Kenia',
  'Lesotho': 'Lesoto',
  'Liberia': 'Liberia',
  'Libya': 'Libia',
  'Madagascar': 'Madagascar',
  'Malawi': 'Malaui',
  'Mali': 'Malí',
  'Mauritania': 'Mauritania',
  'Mauritius': 'Mauricio',
  'Morocco': 'Marruecos',
  'Mozambique': 'Mozambique',
  'Namibia': 'Namibia',
  'Niger': 'Níger',
  'Nigeria': 'Nigeria',
  'Rwanda': 'Ruanda',
  'Sao Tome and Principe': 'Santo Tomé y Príncipe',
  'Senegal': 'Senegal',
  'Seychelles': 'Seychelles',
  'Sierra Leone': 'Sierra Leona',
  'Somalia': 'Somalia',
  'South Africa': 'Sudáfrica',
  'South Sudan': 'Sudán del Sur',
  'Sudan': 'Sudán',
  'Eswatini': 'Esuatini',
  'Tanzania': 'Tanzania',
  'Togo': 'Togo',
  'Tunisia': 'Túnez',
  'Uganda': 'Uganda',
  'Zambia': 'Zambia',
  'Zimbabwe': 'Zimbabue',

  // América del Norte
  'United States of America': 'Estados Unidos',
  'Mexico': 'México',
  'Canada': 'Canadá',
  'Guatemala': 'Guatemala',
  'Belize': 'Belice',
  'Honduras': 'Honduras',
  'El Salvador': 'El Salvador',
  'Nicaragua': 'Nicaragua',
  'Costa Rica': 'Costa Rica',
  'Panama': 'Panamá',
  'Cuba': 'Cuba',
  'Jamaica': 'Jamaica',
  'Haiti': 'Haití',
  'Dominican Republic': 'República Dominicana',

  // América del Sur
  'Brazil': 'Brasil',
  'Argentina': 'Argentina',
  'Chile': 'Chile',
  'Peru': 'Perú',
  'Colombia': 'Colombia',
  'Venezuela': 'Venezuela',
  'Ecuador': 'Ecuador',
  'Bolivia': 'Bolivia',
  'Paraguay': 'Paraguay',
  'Uruguay': 'Uruguay',
  'Guyana': 'Guyana',
  'Suriname': 'Surinam',
  'French Guiana': 'Guayana Francesa',

  // Asia
  'Afghanistan': 'Afganistán',
  'Armenia': 'Armenia',
  'Azerbaijan': 'Azerbaiyán',
  'Bahrain': 'Baréin',
  'Bangladesh': 'Bangladés',
  'Bhutan': 'Bután',
  'Brunei': 'Brunéi',
  'Cambodia': 'Camboya',
  'China': 'China',
  'Cyprus': 'Chipre',
  'Georgia': 'Georgia',
  'India': 'India',
  'Indonesia': 'Indonesia',
  'Iran': 'Irán',
  'Iraq': 'Irak',
  'Israel': 'Israel',
  'Japan': 'Japón',
  'Jordan': 'Jordania',
  'Kazakhstan': 'Kazajistán',
  'Kuwait': 'Kuwait',
  'Kyrgyzstan': 'Kirguistán',
  'Laos': 'Laos',
  'Lebanon': 'Líbano',
  'Malaysia': 'Malasia',
  'Maldives': 'Maldivas',
  'Mongolia': 'Mongolia',
  'Myanmar': 'Birmania',
  'Nepal': 'Nepal',
  'North Korea': 'Corea del Norte',
  'Oman': 'Omán',
  'Pakistan': 'Pakistán',
  'Palestine': 'Palestina',
  'Philippines': 'Filipinas',
  'Qatar': 'Catar',
  'Saudi Arabia': 'Arabia Saudita',
  'Singapore': 'Singapur',
  'South Korea': 'Corea del Sur',
  'Sri Lanka': 'Sri Lanka',
  'Syria': 'Siria',
  'Taiwan': 'Taiwán',
  'Tajikistan': 'Tayikistán',
  'Thailand': 'Tailandia',
  'East Timor': 'Timor Oriental',
  'Turkey': 'Turquía',
  'Turkmenistan': 'Turkmenistán',
  'United Arab Emirates': 'Emiratos Árabes Unidos',
  'Uzbekistan': 'Uzbekistán',
  'Vietnam': 'Vietnam',
  'Yemen': 'Yemen',

  // Europa
  'Albania': 'Albania',
  'Andorra': 'Andorra',
  'Austria': 'Austria',
  'Belarus': 'Bielorrusia',
  'Belgium': 'Bélgica',
  'Bosnia and Herzegovina': 'Bosnia y Herzegovina',
  'Bulgaria': 'Bulgaria',
  'Croatia': 'Croacia',
  'Czech Republic': 'República Checa',
  'Denmark': 'Dinamarca',
  'Estonia': 'Estonia',
  'Finland': 'Finlandia',
  'France': 'Francia',
  'Germany': 'Alemania',
  'Greece': 'Grecia',
  'Hungary': 'Hungría',
  'Iceland': 'Islandia',
  'Ireland': 'Irlanda',
  'Italy': 'Italia',
  'Latvia': 'Letonia',
  'Liechtenstein': 'Liechtenstein',
  'Lithuania': 'Lituania',
  'Luxembourg': 'Luxemburgo',
  'North Macedonia': 'Macedonia del Norte',
  'Malta': 'Malta',
  'Moldova': 'Moldavia',
  'Monaco': 'Mónaco',
  'Montenegro': 'Montenegro',
  'Netherlands': 'Países Bajos',
  'Norway': 'Noruega',
  'Poland': 'Polonia',
  'Portugal': 'Portugal',
  'Romania': 'Rumania',
  'Russia': 'Rusia',
  'San Marino': 'San Marino',
  'Serbia': 'Serbia',
  'Slovakia': 'Eslovaquia',
  'Slovenia': 'Eslovenia',
  'Spain': 'España',
  'Sweden': 'Suecia',
  'Switzerland': 'Suiza',
  'Ukraine': 'Ucrania',
  'United Kingdom': 'Reino Unido',
  'Vatican': 'Vaticano',

  // Australia/Oceanía
  'Australia': 'Australia',
  'New Zealand': 'Nueva Zelanda',
  'Fiji': 'Fiyi',
  'Papua New Guinea': 'Papúa Nueva Guinea',
  'Solomon Islands': 'Islas Salomón',
  'Vanuatu': 'Vanuatu',
  'Samoa': 'Samoa',
  'Kiribati': 'Kiribati',
  'Tonga': 'Tonga',
  'Micronesia': 'Micronesia',
  'Palau': 'Palaos',
  'Marshall Islands': 'Islas Marshall',
  'Nauru': 'Nauru',
  'Tuvalu': 'Tuvalu',
};

// Colores por continente
const continentColors: Record<string, string> = {
  'North America': '#8B7FDB',
  'South America': '#A8D08D',
  'Europe': '#5DD9C1',
  'Africa': '#F4B184',
  'Asia': '#FFD966',
  'Oceania': '#9DC3E6',
};

// URL del archivo TopoJSON del mundo
const geoUrl = 'https://cdn.jsdelivr.net/npm/world-atlas@2/countries-110m.json';

export const WorldMap: React.FC = () => {
  const navigate = useNavigate();
  const [regions, setRegions] = useState<Region[]>([]);

  const [tooltipContent, setTooltipContent] = useState<string>('');
  const [countriesWithSpecies, setCountriesWithSpecies] = useState<Map<string, CountryWithSpecies>>(new Map());

  useEffect(() => {
    loadRegions();
  }, []);

  const loadRegions = async () => {
    try {
      // Obtener todas las regiones
      const { data: regionData } = await supabase
        .from('regiones')
        .select('id, nombre')
        .order('nombre');

      if (regionData) {
        setRegions(regionData);

        // OPTIMIZACIÓN: Una sola consulta para obtener todos los países con su conteo de especies
        // Esto reemplaza 187+ consultas individuales por UNA SOLA consulta
        const { data: countriesData } = await supabase
          .from('paises')
          .select(`
            id,
            nombre,
            region_id,
            regiones!inner (
              nombre
            ),
            especies (
              id
            )
          `);

        // Mapa de países con especies
        const countriesMap = new Map<string, CountryWithSpecies>();

        if (countriesData) {
          for (const country of countriesData) {
            const regionName = (country.regiones as any)?.nombre || '';
            const hasSpecies = country.especies && country.especies.length > 0;

            const countryInfo = {
              countryName: country.nombre,
              regionName: regionName,
              hasSpecies: hasSpecies,
            };

            // Guardar con nombre exacto
            countriesMap.set(country.nombre, countryInfo);

            // También guardar con nombre en minúsculas para matching flexible
            countriesMap.set(country.nombre.toLowerCase(), countryInfo);
          }
        }

        setCountriesWithSpecies(countriesMap);
      }
    } catch (error) {
      console.error('Error loading regions:', error);
    }
  };

  const getRegionFromContinent = (continent: string): string | null => {
    return continentToRegion[continent] || null;
  };

  const handleRegionClick = (continent: string) => {
    const regionName = getRegionFromContinent(continent);
    if (regionName) {
      const region = regions.find((r) => r.nombre === regionName);
      if (region) {
        navigate(`/region/${region.id}`);
      }
    }
  };

  const getCountryContinent = (geo: any): string => {
    const countryName = geo.properties.name;

    // Mapeo de países a continentes
    const northAmerica = ['United States of America', 'Canada', 'Mexico', 'Guatemala', 'Belize', 'Honduras', 'El Salvador', 'Nicaragua', 'Costa Rica', 'Panama', 'Cuba', 'Jamaica', 'Haiti', 'Dominican Republic', 'Bahamas', 'Trinidad and Tobago', 'Barbados', 'Greenland'];
    const southAmerica = ['Brazil', 'Argentina', 'Chile', 'Colombia', 'Peru', 'Venezuela', 'Ecuador', 'Bolivia', 'Paraguay', 'Uruguay', 'Guyana', 'Suriname', 'French Guiana'];
    const europe = ['Russia', 'Germany', 'United Kingdom', 'France', 'Italy', 'Spain', 'Ukraine', 'Poland', 'Romania', 'Netherlands', 'Belgium', 'Czech Republic', 'Greece', 'Portugal', 'Sweden', 'Hungary', 'Belarus', 'Austria', 'Serbia', 'Switzerland', 'Bulgaria', 'Denmark', 'Finland', 'Slovakia', 'Norway', 'Ireland', 'Croatia', 'Moldova', 'Bosnia and Herzegovina', 'Albania', 'Lithuania', 'Slovenia', 'Latvia', 'North Macedonia', 'Estonia', 'Luxembourg', 'Montenegro', 'Malta', 'Iceland', 'Andorra', 'Monaco', 'Liechtenstein', 'San Marino', 'Vatican'];
    const africa = ['Nigeria', 'Ethiopia', 'Egypt', 'Democratic Republic of the Congo', 'Tanzania', 'South Africa', 'Kenya', 'Uganda', 'Algeria', 'Sudan', 'Morocco', 'Angola', 'Ghana', 'Mozambique', 'Madagascar', 'Cameroon', 'Ivory Coast', 'Niger', 'Burkina Faso', 'Mali', 'Malawi', 'Zambia', 'Somalia', 'Senegal', 'Chad', 'Zimbabwe', 'Guinea', 'Rwanda', 'Benin', 'Tunisia', 'Burundi', 'South Sudan', 'Togo', 'Sierra Leone', 'Libya', 'Liberia', 'Central African Republic', 'Mauritania', 'Eritrea', 'Gambia', 'Botswana', 'Namibia', 'Gabon', 'Lesotho', 'Guinea-Bissau', 'Equatorial Guinea', 'Mauritius', 'Eswatini', 'Djibouti', 'Comoros', 'Cape Verde', 'Sao Tome and Principe', 'Seychelles'];
    const asia = ['China', 'India', 'Indonesia', 'Pakistan', 'Bangladesh', 'Japan', 'Philippines', 'Vietnam', 'Turkey', 'Iran', 'Thailand', 'Myanmar', 'South Korea', 'Iraq', 'Afghanistan', 'Saudi Arabia', 'Uzbekistan', 'Malaysia', 'Yemen', 'Nepal', 'North Korea', 'Sri Lanka', 'Kazakhstan', 'Syria', 'Cambodia', 'Jordan', 'Azerbaijan', 'Tajikistan', 'United Arab Emirates', 'Israel', 'Laos', 'Lebanon', 'Kyrgyzstan', 'Turkmenistan', 'Singapore', 'Oman', 'Palestine', 'Kuwait', 'Georgia', 'Mongolia', 'Armenia', 'Qatar', 'Bahrain', 'East Timor', 'Cyprus', 'Bhutan', 'Maldives', 'Brunei'];
    const oceania = ['Australia', 'Papua New Guinea', 'New Zealand', 'Fiji', 'Solomon Islands', 'Micronesia', 'Vanuatu', 'Samoa', 'Kiribati', 'Tonga', 'Palau', 'Marshall Islands', 'Nauru', 'Tuvalu'];

    if (northAmerica.includes(countryName)) return 'North America';
    if (southAmerica.includes(countryName)) return 'South America';
    if (europe.includes(countryName)) return 'Europe';
    if (africa.includes(countryName)) return 'Africa';
    if (asia.includes(countryName)) return 'Asia';
    if (oceania.includes(countryName)) return 'Oceania';

    return 'Other';
  };

  return (
    <div className="w-full max-w-7xl mx-auto px-4">
      <div
        className="bg-white rounded-3xl shadow-2xl p-1 md:p-2 overflow-hidden"
        style={{
          background: 'linear-gradient(135deg, #f8fafc 0%, #e0f2fe 100%)',
        }}
      >
        {/* Contenedor con scroll horizontal para móvil */}
        <div className="overflow-x-auto overflow-y-hidden -mx-4 md:mx-0">
          <div className="min-w-[600px] md:min-w-0">
            <ComposableMap
              projection="geoMercator"
              projectionConfig={{
                scale: window.innerWidth < 768 ? 150 : 130, // Reducido para evitar cortes
                center: [0, 20],
              }}
              style={{
                width: '100%',
                height: 'auto',
              }}
            >
              <Geographies geography={geoUrl}>
                {({ geographies }: { geographies: any[] }) =>
                  geographies.map((geo) => {
                    const countryNameEnglish = geo.properties.name;
                    const continent = getCountryContinent(geo);
                    const regionName = getRegionFromContinent(continent);

                    // Traducir nombre del país de inglés a español
                    const countryNameSpanish = countryNameMap[countryNameEnglish] || countryNameEnglish;

                    // Verificar si este país tiene especies
                    let countryData = countriesWithSpecies.get(countryNameSpanish);
                    if (!countryData) {
                      // Intentar con el nombre original en inglés
                      countryData = countriesWithSpecies.get(countryNameEnglish);
                    }
                    if (!countryData) {
                      // Intentar con lowercase
                      countryData = countriesWithSpecies.get(countryNameSpanish.toLowerCase());
                    }

                    const hasSpecies = countryData?.hasSpecies || false;
                    const isClickable = hasSpecies && regionName !== null;

                    // Color: solo países con especies tienen color, otros son grises
                    const fillColor = hasSpecies ? (continentColors[continent] || '#E5E7EB') : '#E5E7EB';

                    // Nombre a mostrar en tooltip (usar el nombre de la BD si existe, sino el inglés)
                    const displayCountryName = countryData?.countryName || countryNameSpanish;

                    return (
                      <Geography
                        key={geo.rsmKey}
                        geography={geo}
                        fill={fillColor}
                        stroke="#FFFFFF"
                        strokeWidth={0.5}
                        style={{
                          default: {
                            fill: fillColor,
                            stroke: '#FFFFFF',
                            strokeWidth: 0.5,
                            outline: 'none',
                          },
                          hover: {
                            fill: isClickable ? '#10b981' : fillColor,
                            stroke: '#FFFFFF',
                            strokeWidth: 1,
                            outline: 'none',
                            cursor: isClickable ? 'pointer' : 'default',
                            filter: isClickable ? 'brightness(1.1)' : 'none',
                          },
                          pressed: {
                            fill: isClickable ? '#059669' : fillColor,
                            stroke: '#FFFFFF',
                            strokeWidth: 1,
                            outline: 'none',
                          },
                        }}
                        onMouseEnter={() => {
                          if (countryData && regionName) {
                            // Mostrar "Región - País"
                            setTooltipContent(`${regionName} - ${displayCountryName}`);
                          } else if (regionName) {
                            setTooltipContent(`${regionName} - ${displayCountryName}`);
                          } else {
                            setTooltipContent(displayCountryName);
                          }
                        }}
                        onMouseLeave={() => {
                          setTooltipContent('');
                        }}
                        onClick={(e: React.MouseEvent<SVGPathElement>) => {
                          e.preventDefault();
                          if (isClickable && regionName) {
                            handleRegionClick(continent);
                          }
                        }}
                        data-tooltip-id="map-tooltip"
                        data-tooltip-content={tooltipContent}
                      />
                    );
                  })
                }
              </Geographies>
            </ComposableMap>

            <Tooltip
              id="map-tooltip"
              place="top"
              style={{
                backgroundColor: '#1f2937',
                color: '#fff',
                borderRadius: '8px',
                padding: '8px 12px',
                fontSize: '14px',
                fontWeight: '600',
                zIndex: 1000,
              }}
            />
          </div>
        </div>

        {/* Mensaje de ayuda para móvil */}
        <div className="md:hidden mt-4 text-center text-sm text-gray-600">
          <p>💡 Desliza horizontalmente para explorar el mapa completo</p>
        </div>
      </div>

      {/* Leyenda */}
      <div className="mt-6 flex flex-wrap justify-center gap-4">
        {Object.entries(continentToRegion).map(([continent, regionName]) => (
          <div key={continent} className="flex items-center gap-2">
            <div
              className="w-4 h-4 rounded"
              style={{ backgroundColor: continentColors[continent] }}
            />
            <span className="text-sm font-medium text-gray-700">
              {regionName}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
};
