<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\URL;

class AssetServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     *
     * @return void
     */
    public function register()
    {
        //
    }

    /**
     * Bootstrap services.
     *
     * @return void
     */
    public function boot()
    {
        // Force HTTPS in production if behind a proxy
        if (config('app.env') === 'production') {
            URL::forceScheme('https');
        }
        
        // Set the correct asset URL for production
        if (config('app.env') === 'production' && config('app.asset_url')) {
            URL::asset(config('app.asset_url'));
        }
    }
}