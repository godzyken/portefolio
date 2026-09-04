import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { email, redirect_to } = await req.json()

    if (!email) {
      throw new Error('Email is required')
    }

    // 1. Détection dynamique du projet pour le branding
    const isPortfolio = redirect_to?.includes('godzyken.github.io') || redirect_to?.includes('portefolio');

    const config = {
      name: isPortfolio ? 'Godzyken Portfolio' : 'EMAP Services',
      primaryColor: isPortfolio ? '#00D9FF' : '#1E4D8B',
      accentColor: isPortfolio ? '#00D9FF' : '#D17C2E',
      senderEmail: isPortfolio ? 'isgodzy@gmail.com' : (Deno.env.get('SENDER_EMAIL') || 'alveges.mass@emap-82.fr'),
      footer: isPortfolio
        ? 'Emryck Doré — Développeur Flutter & Architecte Logiciel'
        : 'EMAP Services — Plomberie, Chauffage, Climatisation — Grisolles (82)'
    };

    // 2. Initialisation Supabase Admin
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // 3. Génération du lien de récupération
    const { data, error } = await supabaseAdmin.auth.admin.generateLink({
      type: 'recovery',
      email: email,
      options: { redirectTo: redirect_to }
    })

    if (error) throw error
    const recoveryLink = data.properties.action_link

    // 4. Envoi via Brevo API
    const BREVO_API_KEY = Deno.env.get('EMAP_BREVO_APIKEY') || Deno.env.get('BREVO_API_KEY')

    if (!BREVO_API_KEY) {
      throw new Error('Clé API Brevo manquante dans les secrets Supabase.')
    }

    const emailResponse = await fetch('https://api.brevo.com/v3/smtp/email', {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'api-key': BREVO_API_KEY,
      },
      body: JSON.stringify({
        sender: { name: config.name, email: config.senderEmail },
        to: [{ email: email }],
        // Optionnel : ajout d'une copie cachée pour contrôle (isgodzy@gmail.com)
        bcc: isPortfolio ? [] : [{ email: 'isgodzy@gmail.com' }],
        subject: `Réinitialisation de votre mot de passe - ${config.name}`,
        htmlContent: `
          <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #eee; padding: 20px; border-radius: 10px; border-top: 4px solid ${config.primaryColor};">
            <h2 style="color: ${config.primaryColor};">Bonjour,</h2>
            <p>Vous avez demandé la réinitialisation de votre mot de passe pour votre accès Admin <strong>${config.name}</strong>.</p>
            <p>Cliquez sur le bouton ci-dessous pour choisir un nouveau mot de passe :</p>
            <div style="text-align: center; margin: 30px 0;">
              <a href="${recoveryLink}" style="background-color: ${config.accentColor}; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; font-weight: bold; display: inline-block;">Réinitialiser mon mot de passe</a>
            </div>
            <p style="font-size: 12px; color: #666;">Ce lien est valable pendant 60 minutes. Si vous n'êtes pas à l'origine de cette demande, vous pouvez ignorer cet e-mail.</p>
            <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;">
            <p style="font-size: 11px; color: #999; text-align: center;">${config.footer}</p>
          </div>
        `
      })
    })

    if (!emailResponse.ok) {
      const result = await emailResponse.json()
      throw new Error(`Brevo API error: ${JSON.stringify(result)}`)
    }

    return new Response(
      JSON.stringify({ success: true, project: config.name }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
