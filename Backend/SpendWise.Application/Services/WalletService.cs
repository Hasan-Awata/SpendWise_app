using SpendWise.Application.DTOs.Currency;
using SpendWise.Application.DTOs.Wallet;
using SpendWise.Application.Interfaces.Wallets;
using SpendWise.Domain.Common;
using SpendWise.Domain.Constants;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using SpendWise.Domain.ProcessingResults;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SpendWise.Application.Services
{
    public class WalletService : IWalletService
    {
        private readonly IWalletRepository _walletRepo;

        public WalletService(IWalletRepository walletRepo)
        {
            _walletRepo = walletRepo;
        }

        // Helpers methods --------------------------------------------------
        private Wallet MapWalletDTOtoWalletObject(WalletDTO walletDto)
        {
            return new Wallet
            (
                walletDto.WalletId,
                walletDto.CurrencyId,
                walletDto.Balance,
                walletDto.UserId,
                walletDto.IsSaved
            );
        }

        private WalletResponse MapWalletToWalletResponse(Wallet wallet)
        {
            return new WalletResponse
            (
                wallet.WalletId,
                wallet.CurrencyId,
                wallet.Balance,
                wallet.UserId,
                wallet.IsSaved
            );
        }

        // Reading methods --------------------------------------------------
        public async Task<Result<WalletResponse>> GetWalletByIdAsync(int walletId, int userId)
        {
            var wallet = await _walletRepo.GetWalletByIdAsync(walletId, userId);

            if (wallet == null)
                return Result<WalletResponse>.Failure("Wallet was not found.", enErrorType.NotFound);

            return Result<WalletResponse>.Success(MapWalletToWalletResponse(wallet));
        }

        public async Task<Result<IEnumerable<WalletResponse>>> GetUserWalletsAsync(int userId)
        {
            var walletsList = await _walletRepo.GetUserWalletsAsync(userId);

            if (!walletsList.Any())
                return Result<IEnumerable<WalletResponse>>.Success(Enumerable.Empty<WalletResponse>());

            var walletsResponse = walletsList.Select(item => MapWalletToWalletResponse(item)).ToList();

            return Result<IEnumerable<WalletResponse>>.Success(walletsResponse);
        }

        public async Task<Result<IEnumerable<WalletResponse>>> GetWalletsByCurrencyIdAsync(int userId, int currencyId)
        {
            var walletsList = await _walletRepo.GetWalletsByCurrencyIdAsync(userId, currencyId);

            if (!walletsList.Any())
                return Result<IEnumerable<WalletResponse>>.Success(Enumerable.Empty<WalletResponse>());

            var walletsResponse = walletsList.Select(item => MapWalletToWalletResponse(item)).ToList();

            return Result<IEnumerable<WalletResponse>>.Success(walletsResponse);
        }

        public async Task<Result<IEnumerable<WalletResponse>>> GetWalletPairByIdAsync(int userId, int walletId)
        {
            var walletsList = await _walletRepo.GetWalletPairByIdAsync(userId, walletId);

            if (!walletsList.Any())
                return Result<IEnumerable<WalletResponse>>.Success(Enumerable.Empty<WalletResponse>());

            var walletsResponse = walletsList.Select(item => MapWalletToWalletResponse(item)).ToList();

            return Result<IEnumerable<WalletResponse>>.Success(walletsResponse);
        }

        // Writing methods --------------------------------------------------
        public async Task<Result<WalletResponse>> AddWalletAsync(WalletDTO walletDTO)
        {
            // 1 - Input validations --------------------------------------------
            if (walletDTO.Balance < 0)
                return Result<WalletResponse>.Failure("Wallet balance cannot be negative.", enErrorType.Validation);

            if (SupportedCurrencies.GetById(walletDTO.CurrencyId) == null)
                return Result<WalletResponse>.Failure("The specified currency is not supported.", enErrorType.Validation);

            walletDTO.WalletId = -1; // Make sure to send -1 to database (safe practice)

            // 2 - Map data ------------------------------------------------------
            var newWallet = MapWalletDTOtoWalletObject(walletDTO);

            int newWalletId = await _walletRepo.AddWalletAsync(newWallet);

            if (newWalletId == -1)
                return Result<WalletResponse>.Failure("Failed to add the wallet to the database.", enErrorType.Failure);

            newWallet.WalletId = newWalletId;

            // 3 - Form the response ----------------------------------------------
            return Result<WalletResponse>.Success(MapWalletToWalletResponse(newWallet));
        }

        public async Task<Result<WalletResponse>> UpdateWalletAsync(WalletDTO walletDTO)
        {
            // 1 - Input validations --------------------------------------------
            if (walletDTO.Balance < 0)
                return Result<WalletResponse>.Failure("Wallet balance cannot be negative.", enErrorType.Validation);

            if (SupportedCurrencies.GetById(walletDTO.CurrencyId) == null)
                return Result<WalletResponse>.Failure("The specified currency is not supported.", enErrorType.Validation);

            // 2 - Map data ------------------------------------------------------
            var updatedWallet = MapWalletDTOtoWalletObject(walletDTO);

            if (!await _walletRepo.UpdateWalletAsync(updatedWallet))
                return Result<WalletResponse>.Failure("Failed to update the wallet in the database.", enErrorType.Failure);

            // 3 - Form the response ----------------------------------------------
            return Result<WalletResponse>.Success(MapWalletToWalletResponse(updatedWallet));
        }

        public async Task<Result> DeleteWalletAsync(int walletId, int userId)
        {
            if (await _walletRepo.DeleteWalletAsync(walletId, userId))
                return Result.Success();

            return Result.Failure("Failed to delete the wallet from the database.", enErrorType.Failure);
        }
    }
}