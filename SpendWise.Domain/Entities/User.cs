namespace SpendWise.Domain.Entities
{
    public class User
    {
        public int Id { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string HashedPassword { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
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
        public User(string userName, string HashedPassword, string FirstName, string LastName)
        {
            this.UserName = userName;
            this.HashedPassword = HashedPassword;
            this.FirstName = FirstName;
            this.LastName = LastName;
        }
        public User(int ID, string userName, string HashedPassword, string FirstName, string LastName)
        {
            this.Id = ID;
            this.UserName = userName;
            this.HashedPassword = HashedPassword;
            this.FirstName = FirstName;
            this.LastName = LastName;
        }
    }
}
