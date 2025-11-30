<?php

namespace Tests\Feature;

use Tests\TestCase;

class ExampleApiTest extends TestCase
{
    /**
     * Test homepage loads successfully
     */
    public function test_homepage_returns_successful_response()
    {
        $response = $this->get('/');

        $response->assertStatus(200);
    }

    /**
     * Test application environment is set
     */
    public function test_application_environment_is_configured()
    {
        $this->assertNotEmpty(config('app.name'));
        $this->assertNotEmpty(config('app.env'));
    }

    /**
     * Test API ping returns JSON
     */
    public function test_api_returns_json()
    {
        $response = $this->getJson('/api/ping');

        $response->assertHeader('Content-Type', 'application/json');
    }

    /**
     * Test API ping response structure
     */
    public function test_ping_has_timestamp()
    {
        $response = $this->getJson('/api/ping');

        $response->assertJsonStructure([
            'pong',
            'timestamp'
        ]);
    }
}
