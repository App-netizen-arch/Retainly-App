const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY || '';
const OPENROUTER_ENDPOINT = 'https://openrouter.ai/api/v1/chat/completions';
const DEFAULT_MODEL = 'openrouter/free';

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).json({ error: 'Method not allowed' });
  }

  if (!OPENROUTER_API_KEY) {
    return res.status(500).json({ error: 'OpenRouter API key not configured on server.' });
  }

  try {
    const { model, messages } = req.body ?? {};

    const response = await fetch(OPENROUTER_ENDPOINT, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: model ?? DEFAULT_MODEL,
        messages,
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      const message = data?.error?.message ?? `OpenRouter error ${response.status}`;
      return res.status(response.status).json({ error: message });
    }

    const output = data?.choices?.[0]?.message?.content ?? '';
    return res.status(200).json({ output });
  } catch (error) {
    return res.status(500).json({ error: 'AI request failed.' });
  }
};
