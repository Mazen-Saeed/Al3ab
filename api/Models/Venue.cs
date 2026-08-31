namespace api.Models;

public class Venue
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public required string Phone { get; set; }
    public string? Address { get; set; }
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public TimeOnly? OpensAt { get; set; }
    public TimeOnly? ClosesAt { get; set; }
    public DateTime CreatedAt { get; set; }
}
