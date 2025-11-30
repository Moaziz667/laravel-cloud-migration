<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class HealthCheckTest extends TestCase
{
    /**
     * Test health endpoint returns successful response
     */
    public function test_health_endpoint_returns_ok()
    {
        $response = $this->getJson('/api/health');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'status',
                'timestamp',
                'app_name',
                'environment',
                'checks' => [
                    'database',
                    'cache',
                    'storage'
                ]
            ]);
    }

    /**
     * Test health endpoint returns healthy status
     */
    public function test_health_status_is_healthy()
    {
        $response = $this->getJson('/api/health');

        $response->assertJson([
            'status' => 'healthy'
        ]);
    }

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
     * Test database check is included
     */
    public function test_database_check_exists()
    {
        $response = $this->getJson('/api/health');

        $response->assertJsonPath('checks.database.status', 'ok');
    }

    /**
     * Test cache check is included
     */
    public function test_cache_check_exists()
    {
        $response = $this->getJson('/api/health');

        $response->assertJsonPath('checks.cache.status', 'ok');
    }

    /**
     * Test storage check is included
     */
    public function test_storage_check_exists()
    {
        $response = $this->getJson('/api/health');

        $response->assertJsonPath('checks.storage.status', 'ok');
    }
}
