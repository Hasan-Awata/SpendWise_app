using SpendWise.Application.DTOs.Income;
using SpendWise.Application.DTOs.Wallet;
using SpendWise.Application.DTOs.Currency;
using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Application.DTOs.Tag;
using SpendWise.Application.Interfaces.Incomes;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;

namespace SpendWise.Application.Services
{
    public class IncomeService: IIncomeService
    {
        private readonly IIncomeRepository _incomeRepo;
        
        public IncomeService(IIncomeRepository incomeRepo)
        {
            _incomeRepo = incomeRepo;
        }

        // Reading methods --------------------------------------------------
        public async Task<IncomeResponse?> GetIncomeAsync(int incomeId, int userId)
        {
            var income = await _incomeRepo.GetIncomeAsync(incomeId, userId);

            if (income == null)
            {
                return null;
            }

            return new IncomeResponse
            {
                Id = income.Id,
                UserId = income.UserId,
                Title = "Income",
                Amount = income.Amount,
                Wallet = new WalletResponse
                {
                    WalletId = income.Wallet.WalletId,
                    UserId = income.UserId,
                    Balance = income.Wallet.Balance,
                    Currency = new CurrencyResponse
                    {
                        Id = income.Wallet.Currency.Id,
                        CurrencyName = income.Wallet.Currency.CurrencyName,
                        LiveValue = income.Wallet.Currency.LiveValue,
                    },
                },
                IncomeTag = income.IncomeTag == null ? null : new TagResponse 
                { 
                    Id = income.IncomeTag.Id,
                    Label = income.IncomeTag.Label,
                    OwnerId = income.IncomeTag.OwnerId,
                },
            };
        }

        public async Task<PagedResponse<IncomeResponse>> GetIncomeByUserAsync(int userId, PageDTO pageDto)
        {
            var (incomeList, totalCount) = await _incomeRepo.GetIncomeByUserAsync(userId, pageDto.PageNumber, pageDto.PageSize);

            var incomesResponse = incomeList.Select(item => new IncomeResponse
            {
                Id = item.Id,
                UserId = item.UserId,
                Title = "Income",
                Amount = item.Amount,
                Wallet = new WalletResponse
                {
                    WalletId = item.Wallet.WalletId,
                    UserId = item.UserId,
                    Balance = item.Wallet.Balance,
                    Currency = new CurrencyResponse
                    {
                        Id = item.Wallet.Currency.Id,
                        CurrencyName = item.Wallet.Currency.CurrencyName,
                        LiveValue = item.Wallet.Currency.LiveValue,
                    },
                },
                // If IncomeTag is null, the result is null. 
                // Otherwise, it creates the new TagResponse.
                IncomeTag = item.IncomeTag == null ? null : new TagResponse
                {
                    Id = item.IncomeTag.Id,
                    Label = item.IncomeTag.Label,
                    OwnerId = item.IncomeTag.OwnerId,
                },
            });

            return new PagedResponse<IncomeResponse> (incomesResponse, pageDto.PageNumber, pageDto.PageSize, totalCount);
        }

        // Writing methods --------------------------------------------------
        public async Task<IncomeResponse?> AddIncomeAsync(IncomeDTO incomeDto)
        {
            // 1 - Assign the essential data from incomeDTO into an income object
            var newIncome = new Income
            {
                UserId = incomeDto.UserId,
                Amount = incomeDto.Amount,
                Wallet = new Wallet
                {
                    WalletId = incomeDto.Wallet.WalletId,
                    UserId = incomeDto.UserId,
                    Balance = incomeDto.Wallet.Balance,
                    Currency = new Currency
                    {
                        Id = incomeDto.Wallet.Currency.CurrencyId,
                        CurrencyName = incomeDto.Wallet.Currency.CurrencyName,
                        LiveValue = incomeDto.Wallet.Currency.LiveValue,
                    },
                }
            };

            // 2 - Check if the non-essential data existed in the incomeDTO
            Tag? newIncomeTag = null;
            
            if(incomeDto.IncomeTag != null)
            {
                newIncomeTag = new Tag 
                { 
                    Id = incomeDto.IncomeTag.Id,
                    Label = incomeDto.IncomeTag.Label,
                    OwnerId = incomeDto.IncomeTag.OwnerId,
                };
            }

            // 3 - Assign the non-essential data from the incomeDTO into the same income object
            newIncome.IncomeTag = newIncomeTag;

            // 4 - Create a Transaction object to store in the database
            var newTransaction = new Transaction
            {
              UserId = incomeDto.UserId,
              Title = "Added Income",
              Amount = incomeDto.Amount,
              Description = incomeDto.Description,
              Income = newIncome,
                Wallet = new Wallet
                {
                    WalletId = incomeDto.Wallet.WalletId,
                    UserId = incomeDto.UserId,
                    Balance = incomeDto.Wallet.Balance,
                    Currency = new Currency
                    {
                        Id = incomeDto.Wallet.Currency.CurrencyId,
                        CurrencyName = incomeDto.Wallet.Currency.CurrencyName,
                        LiveValue = incomeDto.Wallet.Currency.LiveValue,
                    },
                },
              TransactionTag = newIncomeTag,
              TransactionDate = incomeDto.Date,
              TransactionType = enTransactionType.Addition,
            };

            // 5 - store both the income and the transaction in the database
            int newIncomeId = await _incomeRepo.AddIncomeAsync(newIncome, newTransaction);

            // 6 - Check if the creation succeeded
            if (newIncomeId == -1)
            {
                return null;
            }

            // 7 - Return the created item
            return new IncomeResponse 
            { 
                Id = newIncomeId,
                UserId = incomeDto.UserId,
                Title = newTransaction.Title,
                Amount= newTransaction.Amount,
                Wallet = new WalletResponse
                {
                    WalletId = newIncome.Wallet.WalletId,
                    UserId = newIncome.UserId,
                    Balance = newIncome.Wallet.Balance,
                    Currency = new CurrencyResponse
                    {
                        Id = newIncome.Wallet.Currency.Id,
                        CurrencyName = newIncome.Wallet.Currency.CurrencyName,
                        LiveValue = newIncome.Wallet.Currency.LiveValue,
                    },
                },
                IncomeTag = newIncomeTag == null ? null : new TagResponse
                {
                    Id = newIncomeTag.Id,
                    Label = newIncomeTag.Label,
                    OwnerId = newIncomeTag.OwnerId,
                }
            };
        }
        public async Task<IncomeResponse?> UpdateIncomeAsync(IncomeDTO incomeDto)
        {
            // 1 - Assign the essential data from incomeDTO into an income object
            var updatedIncome = new Income
            {
                Id = incomeDto.Id,
                UserId = incomeDto.UserId,
                Amount = incomeDto.Amount,
                Wallet = new Wallet
                {
                    WalletId = incomeDto.Wallet.WalletId,
                    UserId = incomeDto.UserId,
                    Balance = incomeDto.Wallet.Balance,
                    Currency = new Currency
                    {
                        Id = incomeDto.Wallet.Currency.CurrencyId,
                        CurrencyName = incomeDto.Wallet.Currency.CurrencyName,
                        LiveValue = incomeDto.Wallet.Currency.LiveValue,
                    },
                }
            };

            // 2 - Check if the non-essential data existed in the incomeDTO
            Tag? updatedIncomeTag = null;

            if (incomeDto.IncomeTag != null)
            {
                updatedIncomeTag = new Tag
                {
                    Id = incomeDto.IncomeTag.Id,
                    Label = incomeDto.IncomeTag.Label,
                    OwnerId = incomeDto.IncomeTag.OwnerId,
                };
            }

            // 3 - Assign the non-essential data from the incomeDTO into the same income object
            updatedIncome.IncomeTag = updatedIncomeTag;

            // 4 - Create a Transaction object to store in the database
            var updatedTransaction = new Transaction
            {
                UserId = incomeDto.UserId,
                Title = "Added Income",
                Amount = incomeDto.Amount,
                Description = incomeDto.Description,
                Income = updatedIncome,
                Wallet = new Wallet
                {
                    WalletId = incomeDto.Wallet.WalletId,
                    UserId = incomeDto.UserId,
                    Balance = incomeDto.Wallet.Balance,
                    Currency = new Currency
                    {
                        Id = incomeDto.Wallet.Currency.CurrencyId,
                        CurrencyName = incomeDto.Wallet.Currency.CurrencyName,
                        LiveValue = incomeDto.Wallet.Currency.LiveValue,
                    },
                },
                TransactionTag = updatedIncomeTag,
                TransactionDate = incomeDto.Date,
                TransactionType = enTransactionType.Addition,
            };

            // 5 - store both the income and the transaction in the database
            if (!await _incomeRepo.UpdateIncomeAsync(updatedIncome, updatedTransaction)) return null;


            // 7 - Return the created item
            return new IncomeResponse
            {
                Id = incomeDto.Id,
                UserId = incomeDto.UserId,
                Title = updatedTransaction.Title,
                Amount = updatedTransaction.Amount,
                IncomeTag = updatedIncomeTag == null ? null : new TagResponse
                {
                    Id = updatedIncomeTag.Id,
                    Label = updatedIncomeTag.Label,
                    OwnerId = updatedIncomeTag.OwnerId,
                }
            };
        }

        public async Task<bool> DeleteIncomeAsync(int incomeId)
        {
            return await _incomeRepo.DeleteIncomeAsync(incomeId);
        }
    }
}
