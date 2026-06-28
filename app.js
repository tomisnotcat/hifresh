const { createClient } = supabase;

const SUPABASE_URL = 'https://atwrmjzguzaihdxtjuhu.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF0d3JtanpndXphaWhkeHRqdWh1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI1OTgyNTUsImV4cCI6MjA5ODE3NDI1NX0.GcLPCHR94gxAG5YXCBbrcuL6w0tqRhCWeryotIFCBpc';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
