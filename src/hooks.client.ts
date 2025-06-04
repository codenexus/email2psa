import { createSupabaseLoadClient } from '$lib/supabase'
import { invalidateAll } from '$app/navigation'
import type { HandleClientError } from '@sveltejs/kit'

export const handleError: HandleClientError = ({ error, event }) => {
	console.error('Client error:', error, event)
}

// Initialize Supabase client and handle auth state changes
if (typeof window !== 'undefined') {
	const supabase = createSupabaseLoadClient(fetch)
	
	supabase.auth.onAuthStateChange((event, session) => {
		if (event === 'SIGNED_IN' || event === 'SIGNED_OUT') {
			invalidateAll()
		}
	})
}