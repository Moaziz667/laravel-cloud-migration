<?php

namespace App\Http\Controllers;

use App\Models\Customer;
use App\Models\Invoice;
use App\Models\Order;
use App\Models\Product;
use Carbon\Carbon;
use Illuminate\Contracts\View\View;

class DashboardController extends Controller
{
    public function index(): View
    {
        $totalProducts = Product::count();
        $totalStock = Product::sum('stock');
        $availableProducts = Product::where('stock', '>', 0)->count();
        $pendingOrders = Order::where('order_status', 0)->count();
        $deliveredOrders = Order::where('order_status', '!=', 0)->count();
        $totalCustomers = Customer::count();
        $grossRevenue = Invoice::sum('total');

        $recentOrders = Order::orderByDesc('created_at')->take(5)->get();

        $salesSummary = Invoice::selectRaw('DATE(created_at) as sales_date, SUM(total) as total_sales')
            ->groupBy('sales_date')
            ->orderByDesc('sales_date')
            ->take(7)
            ->get()
            ->sortBy('sales_date')
            ->map(function ($row) {
                return [
                    'label' => Carbon::parse($row->sales_date)->format('M d'),
                    'value' => (float) $row->total_sales,
                ];
            })
            ->values();

        $topProducts = Invoice::selectRaw('product_name, SUM(quantity) as total_quantity')
            ->groupBy('product_name')
            ->orderByDesc('total_quantity')
            ->take(5)
            ->get();

        return view('dashboard', [
            'totalProducts' => $totalProducts,
            'totalStock' => $totalStock,
            'availableProducts' => $availableProducts,
            'pendingOrders' => $pendingOrders,
            'deliveredOrders' => $deliveredOrders,
            'totalCustomers' => $totalCustomers,
            'grossRevenue' => $grossRevenue,
            'recentOrders' => $recentOrders,
            'salesSummary' => $salesSummary,
            'topProducts' => $topProducts,
        ]);
    }
}
