<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Inventory-Management-System</title>

    <!-- BRUTE FORCE: INLINE ALL THE CSS! -->
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Poppins', sans-serif;
            font-size: 14px;
            line-height: 1.8;
            color: #222;
            font-weight: 400;
            background: #fff;
        }
        
        .main {
            padding: 50px 0;
        }
        
        .container {
            width: 100%;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 15px;
        }
        
        .signup {
            margin-bottom: 150px;
        }
        
        .signup-content {
            display: flex;
            padding: 75px 0;
        }
        
        .signup-form, .signup-image {
            width: 50%;
            overflow: hidden;
        }
        
        .signup-form {
            margin-left: 75px;
            margin-right: 75px;
            padding-left: 34px;
        }
        
        .signup-image {
            margin: 0 55px;
            margin-top: 45px;
        }
        
        .form-title {
            margin-bottom: 33px;
            font-size: 30px;
            color: #222;
            font-weight: 600;
            text-align: center;
        }
        
        figure {
            margin-bottom: 50px;
            text-align: center;
        }
        
        figure img {
            max-width: 100%;
            height: auto;
        }
        
        .register-form {
            width: 100%;
        }
        
        .form-group {
            position: relative;
            margin-bottom: 25px;
            overflow: hidden;
        }
        
        .form-group:last-child {
            margin-bottom: 0px;
        }
        
        input {
            width: 100%;
            display: block;
            border: none;
            border-bottom: 1px solid #999;
            padding: 6px 30px;
            font-family: 'Poppins', sans-serif;
            box-sizing: border-box;
            font-size: 14px;
        }
        
        input:focus {
            border-bottom: 1px solid #222;
            outline: none;
        }
        
        label {
            position: absolute;
            left: 0;
            top: 8px;
            color: #999;
            font-size: 16px;
        }
        
        .form-submit {
            display: inline-block;
            background: #6dabe4;
            color: #fff;
            border-bottom: none;
            width: auto;
            padding: 15px 39px;
            border-radius: 5px;
            margin-top: 25px;
            cursor: pointer;
            border: none;
            font-size: 14px;
        }
        
        .form-submit:hover {
            background: #4292dc;
        }
        
        .signup-image-link {
            font-size: 14px;
            color: #222;
            display: block;
            text-align: center;
            text-decoration: none;
        }
        
        .term-service {
            font-size: 13px;
            color: #222;
        }
        
        .label-agree-term {
            font-size: 13px;
            color: #222;
        }
        
        /* Material Icons CSS */
        .zmdi {
            font-family: 'Material-Design-Iconic-Font';
            speak: none;
            font-style: normal;
            font-weight: normal;
            font-variant: normal;
            text-transform: none;
            line-height: 1;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }
        
        .zmdi-account:before { content: '\\f01c'; }
        .zmdi-email:before { content: '\\f02a'; }
        .zmdi-lock:before { content: '\\f033'; }
        .zmdi-lock-outline:before { content: '\\f034'; }
        
        @media screen and (max-width: 768px) {
            .signup-content {
                flex-direction: column;
                justify-content: center;
            }
            
            .signup-form {
                margin-left: 0px;
                margin-right: 0px;
                padding: 0 30px;
            }
            
            .signup-image {
                margin-left: 0px;
                margin-right: 0px;
                margin-top: 50px;
                order: 2;
            }
            
            .signup-form, .signup-image {
                width: 100%;
            }
        }
    </style>
</head>
<body>

    <div class="main">
        <!-- Sing in  Form -->
        <section class="signup">
            <div class="container">
                <div class="signup-content">
                    <div class="signup-form">
                        <h2 class="form-title">Sign up</h2>
                        <form method="POST" action="{{ route('register') }}" class="register-form" id="register-form">
                            @csrf
                            <div class="form-group">
                                <label for="name"><i class="zmdi zmdi-account material-icons-name"></i></label>
                                <input type="text" name="name" id="name" placeholder="Your Name" required=""/>
                            </div>
                            <div class="form-group">
                                <label for="email"><i class="zmdi zmdi-email"></i></label>
                                <input type="email" name="email" id="email" placeholder="Your Email" required=""/>
                            </div>
                            <div class="form-group">
                                <label for="password"><i class="zmdi zmdi-lock"></i></label>
                                <input type="password" name="password" id="password" placeholder="Password" required=""/>
                            </div>
                            <div class="form-group">
                                <label for="password_confirmation"><i class="zmdi zmdi-lock-outline"></i></label>
                                <input type="password" name="password_confirmation" id="password_confirmation" placeholder="Confirm your password" required=""/>
                            </div>
                            <div class="form-group">
                                <input type="checkbox" name="agree-term" id="agree-term" class="agree-term" />
                                <label for="agree-term" class="label-agree-term"><span><span></span></span>I agree all statements in  <a href="#" class="term-service">Terms of service</a></label>
                            </div>
                            <div class="form-group form-button">
                                <input type="submit" name="signup" id="signup" class="form-submit" value="Register"/>
                            </div>
                        </form>
                    </div>
                    <div class="signup-image">
                        <figure><img src="https://via.placeholder.com/400x400/6dabe4/ffffff?text=Sign+Up" alt="sing up image"></figure>
                        <a href="{{ route('login') }}" class="signup-image-link"><b>I am already a member</b></a>
                    </div>
                </div>
            </div>
        </section>

    </div>

    <!-- BRUTE FORCE: NO EXTERNAL JS! Everything inline! -->
</body><!-- This templates was made by Colorlib (https://colorlib.com) -->
</html>