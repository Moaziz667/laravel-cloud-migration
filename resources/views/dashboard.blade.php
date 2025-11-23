@extends('layouts.admin_master')

@section('content')

<main>
    <div class="container-fluid">
        <h1 class="mt-4">Dashboard</h1>
        <ol class="breadcrumb mb-4">
            <li class="breadcrumb-item active">Overview</li>
        </ol>
        <div class="row">
            <div class="col-xl-3 col-md-6">
                <div class="card bg-primary text-white mb-4">
                    <div class="card-body">
                        <div class="text-uppercase small">Total Products</div>
                        <div class="display-4">{{ number_format($totalProducts) }}</div>
                    </div>
                    <div class="card-footer d-flex align-items-center justify-content-between">
                        <a class="small text-white stretched-link" href="{{ route('all.product') }}">Manage products</a>
                        <span class="small text-white">In stock: {{ number_format($availableProducts) }}</span>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-md-6">
                <div class="card bg-success text-white mb-4">
                    <div class="card-body">
                        <div class="text-uppercase small">Units In Stock</div>
                        <div class="display-4">{{ number_format($totalStock) }}</div>
                    </div>
                    <div class="card-footer d-flex align-items-center justify-content-between">
                        <a class="small text-white stretched-link" href="{{ route('available.products') }}">Available items</a>
                        <div class="small text-white"><i class="fas fa-angle-right"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-md-6">
                <div class="card bg-warning text-white mb-4">
                    <div class="card-body">
                        <div class="text-uppercase small">Pending Orders</div>
                        <div class="display-4">{{ number_format($pendingOrders) }}</div>
                    </div>
                    <div class="card-footer d-flex align-items-center justify-content-between">
                        <a class="small text-white stretched-link" href="{{ route('pending.orders') }}">Review queue</a>
                        <span class="small text-white">Delivered: {{ number_format($deliveredOrders) }}</span>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-md-6">
                <div class="card bg-danger text-white mb-4">
                    <div class="card-body">
                        <div class="text-uppercase small">Gross Revenue</div>
                        <div class="display-4">${{ number_format($grossRevenue, 2) }}</div>
                    </div>
                    <div class="card-footer d-flex align-items-center justify-content-between">
                        <span class="small text-white">Customers: {{ number_format($totalCustomers) }}</span>
                        <div class="small text-white"><i class="fas fa-angle-right"></i></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-xl-6">
                <div class="card mb-4">
                    <div class="card-header">
                        <i class="fas fa-chart-area mr-1"></i>
                        Last 7 Days Revenue
                    </div>
                    <div class="card-body"><canvas id="salesChart" width="100%" height="40"></canvas></div>
                </div>
            </div>
            <div class="col-xl-6">
                <div class="card mb-4">
                    <div class="card-header">
                        <i class="fas fa-chart-bar mr-1"></i>
                        Top Selling Products
                    </div>
                    <div class="card-body"><canvas id="topProductsChart" width="100%" height="40"></canvas></div>
                </div>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header">
                <i class="fas fa-table mr-1"></i>
                Recent Orders
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Product</th>
                                <th>Customer Email</th>
                                <th>Qty</th>
                                <th>Status</th>
                                <th>Placed</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($recentOrders as $order)
                                <tr>
                                    <td>{{ $order->id }}</td>
                                    <td>{{ $order->product_name }}</td>
                                    <td>{{ $order->email }}</td>
                                    <td>{{ $order->quantity }}</td>
                                    <td>
                                        @if($order->order_status)
                                            <span class="badge badge-success">Delivered</span>
                                        @else
                                            <span class="badge badge-warning">Pending</span>
                                        @endif
                                    </td>
                                    <td>{{ optional($order->created_at)->format('M d, Y') }}</td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="6" class="text-center text-muted">No orders yet.</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</main>
@endsection

@section('script')
<script>
    const salesSummary = @json($salesSummary);
    const topProducts = @json($topProducts);

    const salesCtx = document.getElementById('salesChart');
    if (salesCtx && salesSummary.length) {
        new Chart(salesCtx, {
            type: 'line',
            data: {
                labels: salesSummary.map(item => item.label),
                datasets: [{
                    label: 'Revenue ($)',
                    data: salesSummary.map(item => item.value),
                    borderColor: '#4e73df',
                    backgroundColor: 'rgba(78, 115, 223, 0.1)',
                    lineTension: 0.3,
                    fill: true,
                }],
            },
            options: {
                maintainAspectRatio: false,
                legend: { display: false },
                scales: {
                    yAxes: [{ ticks: { beginAtZero: true } }],
                    xAxes: [{ gridLines: { display: false } }],
                },
            },
        });
    }

    const topCtx = document.getElementById('topProductsChart');
    if (topCtx && topProducts.length) {
        new Chart(topCtx, {
            type: 'bar',
            data: {
                labels: topProducts.map(item => item.product_name),
                datasets: [{
                    label: 'Units Sold',
                    data: topProducts.map(item => item.total_quantity),
                    backgroundColor: '#1cc88a',
                }],
            },
            options: {
                maintainAspectRatio: false,
                legend: { display: false },
                scales: {
                    yAxes: [{ ticks: { beginAtZero: true } }],
                    xAxes: [{ gridLines: { display: false } }],
                },
            },
        });
    }
</script>
@endsection