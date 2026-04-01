namespace SpendWise.Domain.Entities
{
    public class User
    {
        public int Id { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string HashedPassword { get; set; } = string.Empty;
        public User(int id, string userName)
        {
            Id = id;
            UserName = userName;
        }
        public User(string userName, string HashedPassword)
        {
            this.UserName = userName;
            this.HashedPassword = HashedPassword;
        }
    }
}
