<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Inventory-Management-System</title>

    <!-- BRUTE FORCE: INLINE ALL THE CSS FOR LOGIN TOO! -->
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Arial', sans-serif;
            font-size: 14px;
            line-height: 1.8;
            color: #222;
            font-weight: 400;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .main {
            width: 100%;
            max-width: 1000px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .container {
            width: 100%;
        }
        
        .sign-in {
            background: white;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        
        .signin-content {
            display: flex;
            min-height: 500px;
        }
        
        .signin-image, .signin-form {
            width: 50%;
            padding: 40px;
        }
        
        .signin-image {
            background: linear-gradient(45deg, #6dabe4, #4292dc);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            color: white;
        }
        
        .signin-image figure {
            margin-bottom: 30px;
        }
        
        .signin-image img {
            width: 200px;
            height: 200px;
            border-radius: 50%;
            object-fit: cover;
            border: 5px solid rgba(255,255,255,0.3);
        }
        
        .signup-image-link {
            color: white;
            text-decoration: none;
            font-weight: bold;
            padding: 10px 20px;
            border: 2px solid white;
            border-radius: 25px;
            transition: all 0.3s ease;
        }
        
        .signup-image-link:hover {
            background: white;
            color: #6dabe4;
        }
        
        .signin-form {
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        
        .form-title {
            font-size: 28px;
            color: #333;
            text-align: center;
            margin-bottom: 30px;
            font-weight: 600;
        }
        
        .register-form {
            width: 100%;
        }
        
        .form-group {
            position: relative;
            margin-bottom: 20px;
        }
        
        .form-group label {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #6dabe4;
            font-size: 18px;
            z-index: 2;
        }
        
        .form-group input {
            width: 100%;
            padding: 15px 15px 15px 50px;
            border: 2px solid #e1e1e1;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s ease;
            outline: none;
        }
        
        .form-group input:focus {
            border-color: #6dabe4;
            box-shadow: 0 0 0 3px rgba(109, 171, 228, 0.1);
        }
        
        .label-agree-term {
            font-size: 13px;
            color: #666;
            margin-left: 25px;
        }
        
        .agree-term {
            margin-right: 8px;
        }
        
        .form-submit {
            width: 100%;
            background: linear-gradient(45deg, #6dabe4, #4292dc);
            color: white;
            border: none;
            padding: 15px;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s ease;
            margin-top: 10px;
        }
        
        .form-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(109, 171, 228, 0.4);
        }
        
        .social-login {
            margin-top: 20px;
            text-align: center;
        }
        
        .social-label {
            color: #666;
            font-size: 13px;
            display: block;
            margin-bottom: 15px;
        }
        
        .socials {
            list-style: none;
            display: flex;
            justify-content: center;
            gap: 15px;
        }
        
        .socials li a {
            width: 40px;
            height: 40px;
            background: #f8f9fa;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            color: #666;
            transition: all 0.3s ease;
        }
        
        .socials li a:hover {
            background: #6dabe4;
            color: white;
            transform: translateY(-2px);
        }
        
        @media (max-width: 768px) {
            .signin-content {
                flex-direction: column;
            }
            
            .signin-image, .signin-form {
                width: 100%;
            }
            
            .signin-image {
                order: 2;
                min-height: 200px;
            }
        }
    </style>
</head>
<body>

    <div class="main">
        <!-- Sing in  Form -->
        <section class="sign-in">
            <div class="container">
                <div class="signin-content">
                    <div class="signin-image">
                        <figure><img src="https://via.placeholder.com/300x300/4292dc/ffffff?text=Sign+In" alt="signin image"></figure>
                        <a href="{{ route('register') }}" class="signup-image-link">Create an account</a>
                    </div>

                    <div class="signin-form">
                        <h2 class="form-title">Sign In TEST PIPELINE</h2>
                        <form method="POST" action="{{ route('login') }}" class="register-form" id="login-form">
                        @csrf
                            <div class="form-group">
                                <label for="email"><i class="zmdi zmdi-account material-icons-name"></i></label>
                                <input type="email" name="email" id="email" placeholder="Email" required="" />
                            </div>
                            <div class="form-group">
                                <label for="password"><i class="zmdi zmdi-lock"></i></label>
                                <input type="password" name="password" id="password" placeholder="Password" required=""/>
                            </div>
                            <div class="form-group">
                                <input type="checkbox" name="remember-me" id="remember-me" class="agree-term" />
                                <label for="remember-me" class="label-agree-term"><span><span></span></span>Remember me</label>
                            </div>
                            <div class="form-group form-button">
                                <input type="submit" name="signin" id="signin" class="form-submit" value="Log in"/>
                            </div>
                        </form>
                        <div class="social-login">
                            <span class="social-label">Or login with</span>
                            <ul class="socials">
                                <li><a href="#"><i class="display-flex-center zmdi zmdi-facebook"></i></a></li>
                                <li><a href="#"><i class="display-flex-center zmdi zmdi-twitter"></i></a></li>
                                <li><a href="#"><i class="display-flex-center zmdi zmdi-google"></i></a></li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </section>

    </div>

    <!-- BRUTE FORCE: NO EXTERNAL JS! Everything inline! -->
</body><!-- This templates was made by Colorlib (https://colorlib.com) -->
</html>