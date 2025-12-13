import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import { Navbar } from './components/Navbar';
import { Footer } from './components/Footer';
import { Home } from './pages/Home';
import { Login } from './pages/Login';
import { Register } from './pages/Register';
import { RegionSpecies } from './pages/RegionSpecies';
import { SpeciesDetail } from './pages/SpeciesDetail';
import { SpecimenDetail } from './pages/SpecimenDetail';
import { AdminPanel } from './pages/AdminPanel';
import { SpeciesForm } from './pages/SpeciesForm';
import { SpecimenForm } from './pages/SpecimenForm';

function App() {
  return (
    <Router>
      <AuthProvider>
        <div className="min-h-screen bg-gray-50 flex flex-col">
          <Navbar />
          <div className="flex-grow">
            <Routes>
              <Route path="/" element={<Home />} />
              <Route path="/login" element={<Login />} />
              <Route path="/register" element={<Register />} />
              <Route path="/region/:regionId" element={<RegionSpecies />} />
              <Route path="/species/:speciesId" element={<SpeciesDetail />} />
              <Route path="/specimen/:specimenId" element={<SpecimenDetail />} />
              <Route path="/admin" element={<AdminPanel />} />
              <Route path="/admin/species/new" element={<SpeciesForm />} />
              <Route path="/admin/species/edit/:speciesId" element={<SpeciesForm />} />
              <Route path="/admin/specimens/new" element={<SpecimenForm />} />
              <Route path="/admin/specimens/edit/:specimenId" element={<SpecimenForm />} />
            </Routes>
          </div>
          <Footer />
        </div>
      </AuthProvider>
    </Router>
  );
}

export default App;
