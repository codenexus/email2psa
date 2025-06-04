<script lang="ts">
	import { getContext } from 'svelte';
	import type { SupabaseClient } from '@supabase/supabase-js';
	import type { Writable } from 'svelte/store';
	
	const supabase: SupabaseClient = getContext('supabase');
	const session: Writable<any> = getContext('session');
	
	let email = '';
	let password = '';
	let loading = false;
	let message = '';
	
	async function signUp() {
		loading = true;
		message = '';
		
		const { error } = await supabase.auth.signUp({
			email,
			password
		});
		
		if (error) {
			message = error.message;
		} else {
			message = 'Check your email for confirmation link!';
		}
		
		loading = false;
	}
	
	async function signIn() {
		loading = true;
		message = '';
		
		const { error } = await supabase.auth.signInWithPassword({
			email,
			password
		});
		
		if (error) {
			message = error.message;
		}
		
		loading = false;
	}
	
	async function signOut() {
		await supabase.auth.signOut();
	}
</script>

<div class="max-w-md mx-auto mt-8 p-6 bg-white rounded-lg shadow-md">
	<h1 class="text-2xl font-bold mb-6">Authentication Test</h1>
	
	{#if $session}
		<div class="space-y-4">
			<p class="text-green-600">Welcome! You are signed in as: {$session.user.email}</p>
			<button 
				onclick={signOut}
				class="w-full bg-red-500 text-white py-2 px-4 rounded hover:bg-red-600"
			>
				Sign Out
			</button>
		</div>
	{:else}
		<form class="space-y-4">
			<div>
				<label for="email" class="block text-sm font-medium text-gray-700">Email</label>
				<input 
					id="email"
					type="email" 
					bind:value={email}
					class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
					required
				/>
			</div>
			
			<div>
				<label for="password" class="block text-sm font-medium text-gray-700">Password</label>
				<input 
					id="password"
					type="password" 
					bind:value={password}
					class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
					required
				/>
			</div>
			
			{#if message}
				<p class="text-red-500 text-sm">{message}</p>
			{/if}
			
			<div class="flex space-x-4">
				<button 
					type="button"
					onclick={signIn}
					disabled={loading}
					class="flex-1 bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-600 disabled:opacity-50"
				>
					{loading ? 'Loading...' : 'Sign In'}
				</button>
				
				<button 
					type="button"
					onclick={signUp}
					disabled={loading}
					class="flex-1 bg-green-500 text-white py-2 px-4 rounded hover:bg-green-600 disabled:opacity-50"
				>
					{loading ? 'Loading...' : 'Sign Up'}
				</button>
			</div>
		</form>
	{/if}
</div>