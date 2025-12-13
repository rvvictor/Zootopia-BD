import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export type Database = {
  public: {
    Tables: {
      regiones: {
        Row: {
          id: string;
          nombre: string;
          descripcion: string | null;
          created_at: string;
        };
      };
      paises: {
        Row: {
          id: string;
          nombre: string;
          region_id: string;
          created_at: string;
        };
      };
      ecosistemas: {
        Row: {
          id: string;
          nombre: string;
          descripcion: string | null;
          created_at: string;
        };
      };
      tipos: {
        Row: {
          id: string;
          nombre: string;
          created_at: string;
        };
      };
      estados_conservacion: {
        Row: {
          id: string;
          nombre: string;
          codigo: string;
          created_at: string;
        };
      };
      especies: {
        Row: {
          id: string;
          nombre_comun: string;
          nombre_cientifico: string;
          tipo_id: string;
          pais_id: string;
          ecosistema_id: string;
          habitat_natural: string | null;
          dieta: string | null;
          reproduccion: string | null;
          longevidad: string | null;
          comportamiento: string | null;
          estado_conservacion_id: string;
          descripcion_general: string | null;
          imagen_url: string | null;
          created_at: string;
          updated_at: string;
        };
      };
      ejemplares: {
        Row: {
          id: string;
          nombre: string;
          especie_id: string;
          sexo: 'Macho' | 'Hembra';
          fecha_nacimiento: string | null;
          fecha_ingreso: string;
          habitat_actual: string | null;
          estado_salud: string;
          observaciones: string | null;
          imagen_url: string | null;
          created_at: string;
          updated_at: string;
        };
      };
      profiles: {
        Row: {
          id: string;
          email: string;
          role: 'admin' | 'user';
          created_at: string;
          updated_at: string;
        };
      };
    };
  };
};
