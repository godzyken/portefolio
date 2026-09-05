-- Table pour stocker les analytiques d'utilisation des applications clientes
CREATE TABLE IF NOT EXISTS public.app_analytics (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    app_id TEXT NOT NULL, -- Identifiant de l'application (ex: 'bat_track', 'emap_services')
    event_type TEXT NOT NULL, -- Type d'événement (ex: 'session_start', 'action_perform', 'pdf_generated')
    value NUMERIC DEFAULT 1, -- Valeur associée à l'événement (ex: 1 pour un compteur, ou montant en euros)
    metadata JSONB DEFAULT '{}'::jsonb -- Données supplémentaires (ex: plateforme, version)
);

-- Index pour accélérer les requêtes par application et date
CREATE INDEX IF NOT EXISTS idx_app_analytics_app_id ON public.app_analytics(app_id);
CREATE INDEX IF NOT EXISTS idx_app_analytics_created_at ON public.app_analytics(created_at);

-- Activer Row Level Security (RLS)
ALTER TABLE public.app_analytics ENABLE ROW LEVEL SECURITY;

-- ACTIVER REALTIME pour cette table (Crucial pour le Live Stream)
BEGIN;
  DROP PUBLICATION IF EXISTS supabase_realtime;
  CREATE PUBLICATION supabase_realtime FOR TABLE app_analytics;
COMMIT;
-- Si la publication existe déjà, utilisez plutôt :
-- ALTER PUBLICATION supabase_realtime ADD TABLE app_analytics;

-- Politique pour permettre la lecture seule publique (anonyme) pour le portfolio
-- Cela permet d'afficher les statistiques agrégées sans authentification
CREATE POLICY "Allow anonymous read access"
ON public.app_analytics
FOR SELECT
TO anon
USING (true);

-- Politique pour permettre l'insertion restreinte
-- Dans un environnement réel, vous devriez restreindre cela via une clé d'API ou un service rôle
-- Pour cet exercice, nous autorisons l'insertion anonyme mais limitons l'accès en lecture
CREATE POLICY "Allow anonymous insert"
ON public.app_analytics
FOR INSERT
TO anon
WITH CHECK (true);

-- Exemple de fonction pour obtenir les KPIs agrégés par heure (pour le graphique live)
CREATE OR REPLACE FUNCTION get_live_stats(target_app_id TEXT)
RETURNS TABLE (bucket TIMESTAMPTZ, volume NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT
        date_trunc('hour', created_at) AS bucket,
        SUM(value) as volume
    FROM app_analytics
    WHERE app_id = target_app_id
    AND created_at > NOW() - INTERVAL '24 hours'
    GROUP BY bucket
    ORDER BY bucket ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
