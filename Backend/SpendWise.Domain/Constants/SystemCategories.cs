using SpendWise.Domain.Entities;
using System.Collections.Generic;
using System.Collections.ObjectModel;

namespace SpendWise.Domain.Constants
{
    public static class SystemCategories
    {
        public static readonly IReadOnlyDictionary<int, Category> Map = new Dictionary<int, Category>
        {
            { 1, new Category(1, "Essentials", 1) },
            { 2, new Category(2, "Secondaries", 2) },
            { 3, new Category(3, "Luxuries", 3) },
            { 4, new Category(4, "Savings", 4) },
        }.AsReadOnly();

        /// <summary>
        /// Instantly retrieves a category by its ID, or returns null if not found.
        /// </summary>
        public static Category? GetById(int id)
        {
            return Map.TryGetValue(id, out var category) ? category : null;
        }

        /// <summary>
        /// Returns all categories, useful for populating frontend dropdowns.
        /// </summary>
        public static IEnumerable<Category> GetAll() => Map.Values;
    }
}