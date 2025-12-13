import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabase';

interface Region {
  id: string;
  nombre: string;
}

interface MapRegion {
  name: string;
  path: string;
  color: string;
  labelX: number;
  labelY: number;
}

const mapRegions: MapRegion[] = [
  {
    name: 'América del Norte',
    path: 'M150,80 L180,75 L200,85 L220,75 L240,90 L250,110 L240,140 L220,160 L200,170 L180,165 L160,155 L150,140 L140,120 L135,100 Z',
    color: '#8B7FDB',
    labelX: 180,
    labelY: 120,
  },
  {
    name: 'América del Sur',
    path: 'M220,180 L235,190 L245,210 L250,240 L245,270 L235,290 L220,300 L205,295 L195,280 L190,260 L195,240 L200,220 L210,200 L215,185 Z',
    color: '#8B7FDB',
    labelX: 220,
    labelY: 250,
  },
  {
    name: 'Europa',
    path: 'M450,90 L480,85 L500,95 L510,110 L505,125 L495,135 L475,140 L460,135 L445,120 L440,105 Z',
    color: '#5DD9C1',
    labelX: 475,
    labelY: 115,
  },
  {
    name: 'África',
    path: 'M450,150 L470,155 L490,165 L500,185 L505,210 L500,240 L485,265 L465,280 L445,275 L430,260 L425,235 L430,210 L435,185 L440,165 Z',
    color: '#A8D08D',
    labelX: 465,
    labelY: 220,
  },
  {
    name: 'Asia',
    path: 'M520,70 L580,65 L640,75 L690,85 L720,100 L740,120 L745,145 L735,170 L715,185 L685,190 L655,185 L625,175 L595,165 L570,155 L545,145 L525,130 L515,110 L515,90 Z',
    color: '#F4B184',
    labelX: 640,
    labelY: 130,
  },
  {
    name: 'Australia',
    path: 'M700,260 L730,255 L755,265 L765,280 L760,300 L745,310 L720,315 L695,310 L680,295 L675,275 Z',
    color: '#5DD9C1',
    labelX: 720,
    labelY: 285,
  },
];

export const WorldMap: React.FC = () => {
  const navigate = useNavigate();
  const [regions, setRegions] = useState<Region[]>([]);
  const [hoveredRegion, setHoveredRegion] = useState<string | null>(null);

  useEffect(() => {
    loadRegions();
  }, []);

  const loadRegions = async () => {
    try {
      const { data } = await supabase
        .from('regiones')
        .select('id, nombre')
        .order('nombre');

      setRegions(data || []);
    } catch (error) {
      console.error('Error loading regions:', error);
    }
  };

  const handleRegionClick = (regionName: string) => {
    const region = regions.find((r) => r.nombre === regionName);
    if (region) {
      navigate(`/region/${region.id}`);
    }
  };

  return (
    <div className="w-full max-w-6xl mx-auto px-4">
      <svg
        viewBox="0 0 900 400"
        className="w-full h-auto"
        style={{ filter: 'drop-shadow(0 10px 30px rgba(0,0,0,0.1))' }}
      >
        <defs>
          <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
            <path
              d="M 40 0 L 0 0 0 40"
              fill="none"
              stroke="rgba(100,116,139,0.05)"
              strokeWidth="1"
            />
          </pattern>
        </defs>

        <rect width="900" height="400" fill="#F8FAFC" />
        <rect width="900" height="400" fill="url(#grid)" />

        {mapRegions.map((region) => (
          <g key={region.name}>
            <path
              d={region.path}
              fill={region.color}
              stroke="#FFFFFF"
              strokeWidth="2"
              className="cursor-pointer transition-all duration-300"
              style={{
                opacity: hoveredRegion === region.name ? 0.9 : 0.8,
                transform:
                  hoveredRegion === region.name ? 'scale(1.02)' : 'scale(1)',
                transformOrigin: `${region.labelX}px ${region.labelY}px`,
              }}
              onMouseEnter={() => setHoveredRegion(region.name)}
              onMouseLeave={() => setHoveredRegion(null)}
              onClick={() => handleRegionClick(region.name)}
            />

            <g
              className="cursor-pointer"
              onClick={() => handleRegionClick(region.name)}
              onMouseEnter={() => setHoveredRegion(region.name)}
              onMouseLeave={() => setHoveredRegion(null)}
            >
              <rect
                x={region.labelX - 80}
                y={region.labelY - 20}
                width="160"
                height="40"
                fill="#DC2626"
                rx="6"
                className="transition-all duration-300"
                style={{
                  opacity: hoveredRegion === region.name ? 1 : 0.95,
                  transform:
                    hoveredRegion === region.name ? 'scale(1.05)' : 'scale(1)',
                  transformOrigin: `${region.labelX}px ${region.labelY}px`,
                }}
              />

              <polygon
                points={`${region.labelX - 15},${region.labelY + 20} ${
                  region.labelX + 15
                },${region.labelY + 20} ${region.labelX},${region.labelY + 35}`}
                fill="#DC2626"
                className="transition-all duration-300"
                style={{
                  opacity: hoveredRegion === region.name ? 1 : 0.95,
                }}
              />

              <text
                x={region.labelX}
                y={region.labelY + 5}
                textAnchor="middle"
                fill="white"
                fontSize="18"
                fontWeight="bold"
                className="pointer-events-none select-none"
              >
                {region.name}
              </text>
            </g>
          </g>
        ))}
      </svg>
    </div>
  );
};
