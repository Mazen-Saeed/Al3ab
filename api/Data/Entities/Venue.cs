namespace Al3b.Api.Data.Entities;

public class Venue : SyncedEntity
{
    public required string Name { get; set; }
    public required string Phone { get; set; }
    public string? Address { get; set; }
    public decimal? Latitude { get; set; }
    public decimal? Longitude { get; set; }

    // If ClosesAt <= OpensAt, the venue closes the next day (e.g. 14:00 -> 03:00).
    public TimeOnly? OpensAt { get; set; }
    public TimeOnly? ClosesAt { get; set; }

    // Set by the backend on every sync call from the shop PC, even empty ones.
    public DateTime? LastSyncedAt { get; set; }

    // The one device allowed to run this shop offline (PC, tablet or phone).
    // Null = no shop device registered yet. The backend accepts sync only from this device.
    public Guid? ShopDeviceId { get; set; }
    public Device? ShopDevice { get; set; }

    // Where customers pay. Per method: the owner's payment link (the shop PC draws a QR from it)
    // and the account written out for people to type if the scan fails. InstaPay takes a handle
    // or a phone number, the wallet a phone number. Null = not shown at checkout.
    public string? InstapayLink { get; set; }
    public string? InstapayHandle { get; set; }
    public string? InstapayPhone { get; set; }
    public string? WalletLink { get; set; }
    public string? WalletPhone { get; set; }

    // The venue's subscription is paid outside the apps (Instapay / Vodafone Cash) and moved forward by
    // hand. The last day it is covered. Null = not set yet. Changed on the backend only; the shop PC and
    // owner app just show it. Past this date nothing is locked: the shop PC shows a warning.
    public DateOnly? PaidUntil { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
