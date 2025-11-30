<?php

namespace Tests\Feature;

use Tests\TestCase;

class HealthCheckTest extends TestCase
{
    /**
     * Test ping endpoint returns pong
     */
    public function test_ping_endpoint_returns_pong()
    {
        $response = $this->getJson('/api/ping');

        $response->assertStatus(200)
            ->assertJson([
                'pong' => true
            ]);
    }

    /**
     * Test health endpoint returns response
     */
    public function test_health_endpoint_returns_response()
    {
        $response = $this->getJson('/api/health');

        $response->assertJsonStructure([
            'status',
            'timestamp',
            'app_name',
            'environment',
            'checks'
        ]);
    }

    /**
     * Test health endpoint has required checks
     */
    public function test_health_endpoint_has_checks()
    {
        $response = $this->getJson('/api/health');

        $response->assertJsonStructure([
            'checks' => [
                'cache',
                'storage'
            ]
        ]);
    }
}
