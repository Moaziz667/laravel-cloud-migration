<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;

class ExampleApiTest extends TestCase
{
    use RefreshDatabase;

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
        $this->assertNotEmpty(config('app.key'));
    }

    /**
     * Test database connection works
     */
    public function test_database_connection_works()
    {
        $this->assertDatabaseCount('users', 0);
    }

    /**
     * Test user can be created
     */
    public function test_user_can_be_created()
    {
        $user = User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com'
        ]);

        $this->assertDatabaseHas('users', [
            'email' => 'test@example.com'
        ]);
    }

    /**
     * Test API returns JSON
     */
    public function test_api_returns_json()
    {
        $response = $this->getJson('/api/ping');

        $response->assertHeader('Content-Type', 'application/json');
    }
}
