-- Migration: services + rationales + packs pour AMOA et Desktop
-- À exécuter dans le SQL Editor Supabase (une seule fois).

-- 1) Services (FK pour rationale / packs)
insert into portfolio_services (
  id, title, description, features, icon, image_url, category,
  priority, active, base_price, price_unit, price_note
) values
(
  'desktop-dev',
  'Applications Desktop',
  'Applications de bureau Windows, macOS et Linux avec Flutter — une seule base de code',
  '["💻 Multi-OS (Windows, macOS, Linux)", "⚡ Performances natives", "🎨 UI adaptée au desktop", "🔗 Intégration système (fichiers, notifications…)"]'::jsonb,
  'desktop',
  'assets/images/services/flutter_image.webp',
  'development',
  3,
  true,
  9000,
  'à partir de',
  'Flutter Windows / macOS / Linux'
),
(
  'amoa-conseil',
  'Conseil AMOA',
  'Accompagnement AMOA pour cadrer, piloter et sécuriser vos projets digitaux de bout en bout',
  '["📋 Cadrage & expression de besoins", "🎯 Pilotage & gouvernance", "✅ Recette & critères d''acceptation", "🚀 Mise en production & conduite du changement"]'::jsonb,
  'assignment',
  'assets/images/services/ui_ux_design_service.webp',
  'amoa',
  0,
  true,
  4500,
  'à partir de',
  'mission courte de cadrage ou pilotage'
)
on conflict (id) do update set
  title = excluded.title,
  description = excluded.description,
  features = excluded.features,
  icon = excluded.icon,
  image_url = excluded.image_url,
  category = excluded.category,
  priority = excluded.priority,
  active = excluded.active,
  base_price = excluded.base_price,
  price_unit = excluded.price_unit,
  price_note = excluded.price_note;

-- 2) Rationales
insert into portfolio_pricing_rationale (
  service_id, intro_text, market_comparison, portage_breakdown, anonymized_example
) values
(
  'desktop-dev',
  'Les applications de bureau (Windows, macOS, Linux) avec Flutter sont facturées sur devis : le prix dépend du nombre de modules, des intégrations système et du niveau de finition UI.',
  '[
    {"label":"Outil métier simple (quelques écrans)","freelance_range":"3 000 à 6 000 €","agency_range":"7 000 à 12 000 €"},
    {"label":"Application desktop avec backend / sync","freelance_range":"6 000 à 12 000 €","agency_range":"12 000 à 22 000 €"},
    {"label":"Suite desktop complète (multi-modules, offline)","freelance_range":"12 000 € et +","agency_range":"22 000 € et +"}
  ]'::jsonb,
  '{"frais_gestion_pct":7,"coefficient_transformation":0.65627563,"note":"En portage salarial, une partie du montant facturé couvre les frais de gestion et les charges."}'::jsonb,
  '{"title":"Exemple : outil de gestion interne desktop","invoice_ht":11000,"base_calcul":10230,"remuneration_brute":6714,"note":"Montants indicatifs."}'::jsonb
),
(
  'amoa-conseil',
  'Le conseil AMOA se facture en mission ou au forfait selon la durée, le niveau d’implication et la complexité du SI. Voici les ordres de grandeur constatés et la construction de la rémunération en portage.',
  '[
    {"label":"Cadrage court (ateliers + cahier des charges)","freelance_range":"2 500 à 5 000 €","agency_range":"5 000 à 10 000 €"},
    {"label":"Pilotage projet (2–4 mois, partiel)","freelance_range":"6 000 à 15 000 €","agency_range":"12 000 à 30 000 €"},
    {"label":"AMOA complète (cadrage → recette → MEP)","freelance_range":"15 000 € et +","agency_range":"30 000 € et +"}
  ]'::jsonb,
  '{"frais_gestion_pct":7,"coefficient_transformation":0.65627563,"note":"Même mécanique que pour le développement."}'::jsonb,
  '{"title":"Exemple : cadrage + pilotage (3 mois)","invoice_ht":9000,"base_calcul":8370,"remuneration_brute":5493,"note":"Illustration ; devis après échange."}'::jsonb
)
on conflict (service_id) do update set
  intro_text = excluded.intro_text,
  market_comparison = excluded.market_comparison,
  portage_breakdown = excluded.portage_breakdown,
  anonymized_example = excluded.anonymized_example;

-- 3) Packs AMOA (évite les doublons si déjà présents)
insert into portfolio_pricing_packs (
  service_id, name, price, price_unit, description, features, priority, is_featured, active
)
select * from (values
  ('amoa-conseil', 'Cadrage express', 4500::numeric, '€',
   'Ateliers + expression de besoins + livrable de cadrage',
   '["Ateliers métiers", "Cahier des charges léger", "Priorisation du backlog", "Restitution écrite"]'::jsonb,
   1, true, true),
  ('amoa-conseil', 'Pilotage 3 mois', 9000::numeric, '€',
   'Suivi de projet partiel sur 3 mois',
   '["Animation des comités", "Suivi jalons & risques", "Reporting sponsor", "Interface métiers / tech"]'::jsonb,
   2, false, true),
  ('amoa-conseil', 'AMOA complète', 15000::numeric, '€',
   'De la cadrage à la mise en production',
   '["Cadrage", "Pilotage", "Recette / UAT", "Accompagnement MEP"]'::jsonb,
   3, false, true),
  ('desktop-dev', 'Starter desktop', 9000::numeric, '€',
   'Outil métier simple multi-OS',
   '["Windows / macOS / Linux", "UI desktop", "Packaging installateur"]'::jsonb,
   1, true, true),
  ('desktop-dev', 'Métier + sync', 14000::numeric, '€',
   'App desktop avec backend / synchronisation',
   '["Sync API", "Auth", "Mode offline léger"]'::jsonb,
   2, false, true)
) as v(service_id, name, price, price_unit, description, features, priority, is_featured, active)
where not exists (
  select 1 from portfolio_pricing_packs p
  where p.service_id = v.service_id and p.name = v.name
);

-- Vérifications
-- select id, title, base_price from portfolio_services where id in ('desktop-dev','amoa-conseil');
-- select service_id, left(intro_text,60) from portfolio_pricing_rationale where service_id in ('desktop-dev','amoa-conseil');
-- select service_id, name, price from portfolio_pricing_packs where service_id in ('desktop-dev','amoa-conseil');
