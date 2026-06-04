using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi;
using SpendWise.Application.Interfaces;
using SpendWise.Application.Interfaces.Authentication;
using SpendWise.Application.Interfaces.Categories;
using SpendWise.Application.Interfaces.ExchangeRate;
using SpendWise.Application.Interfaces.Expenses;
using SpendWise.Application.Interfaces.FixedObligations;
using SpendWise.Application.Interfaces.Incomes;
using SpendWise.Application.Interfaces.OcrScanning;
using SpendWise.Application.Interfaces.SavingGoals;
using SpendWise.Application.Interfaces.SharedDebts;
using SpendWise.Application.Interfaces.Tags;
using SpendWise.Application.Interfaces.Transactions;
using SpendWise.Application.Interfaces.Users;
using SpendWise.Application.Interfaces.Wallets;
using SpendWise.Application.Services;
using SpendWise.Infrastructure.ExternalServices;
using SpendWise.Infrastructure.Repositories;
using SpendWise.Middlewares;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.RateLimiting;

var builder = WebApplication.CreateBuilder(args);

// ── Caching ──────────────────────────────────────────────────────────────
builder.Services.AddMemoryCache(); 

// ── Controllers & JSON ───────────────────────────────────────────────────
builder.Services.AddControllers()
    .AddJsonOptions(options =>
        options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter()));

// ── Rate Limiting ────────────────────────────────────────────────────────
builder.Services.AddRateLimiter(options =>
{
    options.AddFixedWindowLimiter("Fixed", limiterOptions =>
    {
        limiterOptions.PermitLimit = 100;
        limiterOptions.Window = TimeSpan.FromMinutes(1);
        limiterOptions.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
        limiterOptions.QueueLimit = 2; 
    });

    options.OnRejected = async (context, token) =>
    {
        context.HttpContext.Response.StatusCode = StatusCodes.Status429TooManyRequests;
        await context.HttpContext.Response.WriteAsync("Too many requests. Please try again later.", cancellationToken: token);
    };
});

// ── Swagger with JWT Bearer ───────────────────────────────────────────────
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Description = "Enter your JWT token.",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT"
    });

    options.AddSecurityRequirement(document => new OpenApiSecurityRequirement
    {
        [new OpenApiSecuritySchemeReference("Bearer", document)] = []
    });
});


// ── Dependency Injections ──────────────────────────────────────────────────
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IUserService, UserService>();

builder.Services.AddScoped<IAuthService, AuthService>();

builder.Services.AddScoped<IIncomeService, IncomeService>();
builder.Services.AddScoped<IIncomeRepository, IncomeRepository>();

builder.Services.AddScoped<IWalletService, WalletService>();
builder.Services.AddScoped<IWalletRepository, WalletRepository>();

builder.Services.AddScoped<ITagService,  TagService>();
builder.Services.AddScoped<ITagRepository, TagRepository>();

builder.Services.AddScoped<IExpenseService, ExpenseService>();
builder.Services.AddScoped<IExpenseRepository, ExpenseRepository>();

builder.Services.AddScoped<ISavingGoalService, SavingGoalsService>();
builder.Services.AddScoped<ISavingGoalRepository, SavingGoalRepository>();

builder.Services.AddScoped<ICategoryBudgetService, CategoryBudgetService>();
builder.Services.AddScoped<ICategoryBudgetRepository, CategoryBudgetRepository>();


builder.Services.AddScoped<ISharedDebtRepository, SharedDebtRepository>();
builder.Services.AddScoped<ISharedDebtService, SharedDebtService>();

builder.Services.AddScoped<IFixedObligationsService, FixedObligationsService>();
builder.Services.AddScoped<IFixedObligationRepository, FixedObligationRepository>();

builder.Services.AddScoped<ITransactionService, TransactionService>();
builder.Services.AddScoped<ITransactionRepository, TransactionRepository>();

builder.Services.AddHttpClient<IExchangeRateService, ExchangeRateService>();

builder.Services.AddSingleton<IOcrService, GeminiOcrService>();

builder.Services.AddScoped<IFixedIncomeService, FixedIncomeService>();
builder.Services.AddScoped<IFixedIncomeRepository, FixedIncomeRepository>();
// ── JWT Authentication ────────────────────────────────────────────────────
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var secretKey = jwtSettings["SecretKey"]!;

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidAudience = jwtSettings["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(
        Encoding.UTF8.GetBytes(secretKey))
    };
});

builder.Services.AddAuthorization();

// ── Allowing all requests for testing ────────────────────────────────────────────────────
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        builder => builder.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
});

// ── Register Global Exception Handling ─────────────────────────────────────
builder.Services.AddExceptionHandler<SpendWise.Middlewares.GlobalExceptionHandler>();
builder.Services.AddProblemDetails(); // Required to standardize the JSON output

// ── Register Schedulers ─────────────────────────────────────
builder.Services.AddHostedService<FixedIncomeScheduler>();
builder.Services.AddHostedService<FixedExpenseScheduler>();
builder.Services.AddHostedService<BudgetScheduler>();
builder.Services.AddHostedService<DebtReminderScheduler>();

// ─────────────────────────────────────────────────────────────────────────
var app = builder.Build();

app.UseExceptionHandler();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
app.UseHttpsRedirection();
app.UseSecurityHeaders();
app.UseCors("AllowAll"); // Delete on actual deployment
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers().RequireRateLimiting("Fixed");

app.Run();