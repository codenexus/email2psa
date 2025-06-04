import { createSupabaseLoadClient } from '$lib/supabase.js'
import { PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY } from '$env/static/public'
import type { LayoutLoad } from './$types'

export const load: LayoutLoad = async ({ fetch, data, depends }) => {
	depends('supabase:auth')

	const supabase = createSupabaseLoadClient(fetch)

	const {
		data: { session }
	} = await supabase.auth.getSession()

	const {
		data: { user }
	} = await supabase.auth.getUser()

	return {
		supabase,
		session,
		user
	}
}