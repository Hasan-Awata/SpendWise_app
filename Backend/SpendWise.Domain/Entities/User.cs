namespace SpendWise.Domain.Entities
{
    public class User
    {
        public int Id { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string HashedPassword { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string RefreshToken { get; set; } = string.Empty;
        public DateTime RefreshTokenExpiryTime { get; set; }
        public User(int id, string userName)
        {
            Id = id;
            UserName = userName;
        }
        public User(string userName, string HashedPassword, string FirstName, string LastName)
        {
            this.UserName = userName;
            this.HashedPassword = HashedPassword;
            this.FirstName = FirstName;
            this.LastName = LastName;
        }
        public User(int ID, string userName, string HashedPassword, string FirstName, string LastName, string RefreshToken, DateTime RefreshTokenExpiryTime)
        {
            this.Id = ID;
            this.UserName = userName;
            this.HashedPassword = HashedPassword;
            this.FirstName = FirstName;
            this.LastName = LastName;
            this.RefreshToken = RefreshToken;
            this.RefreshTokenExpiryTime = RefreshTokenExpiryTime;
        }
    }
}
