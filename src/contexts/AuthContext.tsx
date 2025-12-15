import React, { createContext, useContext, useEffect, useState } from 'react';
import { User, Session } from '@supabase/supabase-js';
import { supabase } from '../lib/supabase';

interface Profile {
  id: number;
  correo: string;
  rol_id: number;
  role?: 'admin' | 'user';
}

interface AuthContextType {
  user: User | null;
  profile: Profile | null;
  session: Session | null;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
  isAdmin: () => boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setUser(session?.user ?? null);
      if (session?.user) {
        loadProfile(session.user.email!);
      } else {
        setLoading(false);
      }
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      (async () => {
        setSession(session);
        setUser(session?.user ?? null);
        if (session?.user) {
          await loadProfile(session.user.email!);
        } else {
          setProfile(null);
          setLoading(false);
        }
      })();
    });

    return () => subscription.unsubscribe();
  }, []);

  const loadProfile = async (email: string) => {
    try {
      const { data, error } = await supabase
        .from('usuarios')
        .select('id, correo, rol_id')
        .eq('correo', email)
        .maybeSingle();

      if (error) throw error;

      console.log('📊 Profile data loaded:', data); // DEBUG

      if (data) {
        const profileData: Profile = {
          id: data.id,
          correo: data.correo,
          rol_id: data.rol_id,
          role: data.rol_id === 1 ? 'admin' : 'user' // 1 = admin, 2 = user
        };
        console.log('✅ Profile processed:', profileData); // DEBUG
        setProfile(profileData);
      }
    } catch (error) {
      console.error('Error loading profile:', error);
    } finally {
      setLoading(false);
    }
  };

  const signIn = async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) throw error;
  };

  const signUp = async (email: string, password: string) => {
    // Primero crear usuario en Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password
    });
    if (authError) throw authError;

    // Luego crear registro en tabla usuarios
    if (authData.user) {
      try {
        const { error: dbError } = await supabase
          .from('usuarios')
          .insert({
            correo: email,
            password: 'supabase_auth', // Placeholder, la auth real es por Supabase
            rol_id: 2 // rol 'user' por defecto
          });

        if (dbError) {
          console.error('Error creating user in usuarios:', dbError);
          // No lanzar error aquí, el usuario ya está creado en auth
        }
      } catch (err) {
        console.error('Failed to create user in usuarios table:', err);
        // El usuario está en auth, solo falta en usuarios
      }
    }
  };

  const signOut = async () => {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
  };

  const isAdmin = () => {
    return profile?.role === 'admin';
  };

  return (
    <AuthContext.Provider value={{ user, profile, session, loading, signIn, signUp, signOut, isAdmin }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
