<script lang="ts">
	import '../app.css';
	import { setContext } from 'svelte';
	import { writable } from 'svelte/store';
	import { invalidateAll } from '$app/navigation';
	import type { LayoutData } from './$types';
	
	let { children, data }: { children: any; data: LayoutData } = $props();
	
	// Create reactive stores for auth state
	const session = writable(data.session);
	const user = writable(data.user);
	
	// Update stores when data changes
	$effect(() => {
		session.set(data.session);
		user.set(data.user);
	});
	
	// Listen for auth changes and update stores
	$effect(() => {
		const { data: authListener } = data.supabase.auth.onAuthStateChange(
			async (event, newSession) => {
				if (event === 'SIGNED_IN' || event === 'SIGNED_OUT' || event === 'TOKEN_REFRESHED') {
					session.set(newSession);
					user.set(newSession?.user ?? null);
					await invalidateAll();
				}
			}
		);
		
		return () => {
			authListener.subscription.unsubscribe();
		};
	});
	
	// Provide reactive stores to child components
	setContext('supabase', data.supabase);
	setContext('session', session);
	setContext('user', user);
</script>

{@render children()}