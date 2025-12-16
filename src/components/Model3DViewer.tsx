import React, { useEffect, useRef } from 'react';
import '@google/model-viewer';

interface Model3DViewerProps {
    modelUrl?: string | null;
    fallbackImageUrl?: string | null;
    altText?: string;
}

// Declarar el tipo para el elemento model-viewer
declare global {
    namespace JSX {
        interface IntrinsicElements {
            'model-viewer': React.DetailedHTMLProps<
                React.HTMLAttributes<HTMLElement> & {
                    src?: string;
                    alt?: string;
                    'auto-rotate'?: boolean;
                    'camera-controls'?: boolean;
                    'shadow-intensity'?: string;
                    'environment-image'?: string;
                    loading?: string;
                    poster?: string;
                    style?: React.CSSProperties;
                },
                HTMLElement
            >;
        }
    }
}

export const Model3DViewer: React.FC<Model3DViewerProps> = ({
    modelUrl,
    fallbackImageUrl,
    altText = 'Modelo 3D'
}) => {
    const modelViewerRef = useRef<HTMLElement>(null);

    useEffect(() => {
        // Asegurar que el web component esté cargado
        if (modelViewerRef.current && modelUrl) {
            const modelViewer = modelViewerRef.current as any;
            modelViewer.addEventListener('error', (event: any) => {
                console.error('Error loading 3D model:', event);
            });
        }
    }, [modelUrl]);

    // Función para detectar si es una URL de Sketchfab embed
    const isSketchfabEmbed = (url: string): boolean => {
        return url.includes('sketchfab.com/models/') && url.includes('/embed');
    };

    // Función para extraer el UID del modelo de Sketchfab
    const getSketchfabUID = (url: string): string | null => {
        const match = url.match(/models\/([a-f0-9]+)/);
        return match ? match[1] : null;
    };

    // Si hay modelo 3D
    if (modelUrl) {
        // Si es una URL de embed de Sketchfab, usar iframe
        if (isSketchfabEmbed(modelUrl)) {
            return (
                <div className="w-full h-full">
                    <iframe
                        title={altText}
                        frameBorder="0"
                        allowFullScreen
                        allow="autoplay; fullscreen; xr-spatial-tracking"
                        src={modelUrl}
                        className="w-full h-full min-h-[400px] md:min-h-[500px]"
                        style={{ border: 'none' }}
                    />
                </div>
            );
        }

        // Si es solo el UID de Sketchfab (sin /embed), construir la URL
        const uid = getSketchfabUID(modelUrl);
        if (uid && !modelUrl.includes('/embed')) {
            const embedUrl = `https://sketchfab.com/models/${uid}/embed`;
            return (
                <div className="w-full h-full">
                    <iframe
                        title={altText}
                        frameBorder="0"
                        allowFullScreen
                        allow="autoplay; fullscreen; xr-spatial-tracking"
                        src={embedUrl}
                        className="w-full h-full min-h-[400px] md:min-h-[500px]"
                        style={{ border: 'none' }}
                    />
                </div>
            );
        }

        // Si es un archivo .glb o .gltf, usar model-viewer
        if (modelUrl.endsWith('.glb') || modelUrl.endsWith('.gltf')) {
            return (
                <div className="w-full h-full">
                    <model-viewer
                        ref={modelViewerRef}
                        src={modelUrl}
                        alt={altText}
                        auto-rotate={true}
                        camera-controls={true}
                        shadow-intensity="1"
                        environment-image="neutral"
                        loading="eager"
                        poster={fallbackImageUrl || undefined}
                        style={{
                            width: '100%',
                            height: '100%',
                            minHeight: '400px',
                        }}
                    />
                </div>
            );
        }
    }

    // Fallback a imagen 2D si no hay modelo 3D
    if (fallbackImageUrl) {
        return (
            <img
                src={fallbackImageUrl}
                alt={altText}
                className="w-full h-full object-cover"
            />
        );
    }

    // Si no hay ni modelo 3D ni imagen
    return (
        <div className="w-full h-full flex items-center justify-center text-gray-400 text-2xl">
            Sin imagen disponible
        </div>
    );
};
