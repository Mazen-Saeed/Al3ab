using System.Linq.Expressions;
using Al3b.Api.Data.Entities;
using Al3b.Api.Data.Enums;
using Microsoft.EntityFrameworkCore;

namespace Al3b.Api.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    // DbSet names become table names in snake_case (SessionsUnits -> sessions_units).
    public DbSet<Venue> Venues => Set<Venue>();
    public DbSet<Staff> Staff => Set<Staff>();
    public DbSet<StaffVenue> StaffVenues => Set<StaffVenue>();
    public DbSet<Room> Rooms => Set<Room>();
    public DbSet<RoomGroup> RoomGroups => Set<RoomGroup>();
    public DbSet<UnitType> UnitTypes => Set<UnitType>();
    public DbSet<PriceCategory> PriceCategories => Set<PriceCategory>();
    public DbSet<Unit> Units => Set<Unit>();
    public DbSet<Customer> Customers => Set<Customer>();
    public DbSet<WalkInCustomer> WalkInCustomers => Set<WalkInCustomer>();
    public DbSet<Reservation> Reservations => Set<Reservation>();
    public DbSet<ReservationUnit> ReservationsUnits => Set<ReservationUnit>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<StockItem> StockItems => Set<StockItem>();
    public DbSet<StockMovement> StockMovements => Set<StockMovement>();
    public DbSet<Purchase> Purchases => Set<Purchase>();
    public DbSet<Session> Sessions => Set<Session>();
    public DbSet<SessionUnit> SessionsUnits => Set<SessionUnit>();
    public DbSet<SessionProduct> SessionsProducts => Set<SessionProduct>();
    public DbSet<Bill> Bills => Set<Bill>();
    public DbSet<BillItem> BillItems => Set<BillItem>();
    public DbSet<Shift> Shifts => Set<Shift>();
    public DbSet<CashMovement> CashMovements => Set<CashMovement>();
    public DbSet<RemoteCommand> RemoteCommands => Set<RemoteCommand>();
    public DbSet<Device> Devices => Set<Device>();

    protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
    {
        // Every decimal is money -> numeric(10,2), unless a configuration overrides it (Venue lat/long).
        configurationBuilder.Properties<decimal>().HavePrecision(10, 2);

        // Enums are stored as text ("Pending"), not numbers.
        configurationBuilder.Properties<Role>().HaveConversion<string>();
        configurationBuilder.Properties<UnitStatus>().HaveConversion<string>();
        configurationBuilder.Properties<ReservationStatus>().HaveConversion<string>();
        configurationBuilder.Properties<SessionStatus>().HaveConversion<string>();
        configurationBuilder.Properties<SessionMode>().HaveConversion<string>();
        configurationBuilder.Properties<PaymentMethod>().HaveConversion<string>();
        configurationBuilder.Properties<CashMovementType>().HaveConversion<string>();
        configurationBuilder.Properties<RemoteCommandStatus>().HaveConversion<string>();
        configurationBuilder.Properties<DevicePlatform>().HaveConversion<string>();
        configurationBuilder.Properties<StockMovementKind>().HaveConversion<string>();
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Picks up every IEntityTypeConfiguration in Data/Configurations.
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);

        foreach (var entityType in modelBuilder.Model.GetEntityTypes().ToList())
        {
            // Never cascade deletes. Rows are soft-deleted; a real DELETE of a parent should fail loudly.
            foreach (var foreignKey in entityType.GetForeignKeys())
                foreignKey.DeleteBehavior = DeleteBehavior.Restrict;

            // Hide soft-deleted rows from every query: adds WHERE deleted_at IS NULL.
            if (typeof(SyncedEntity).IsAssignableFrom(entityType.ClrType))
            {
                var e = Expression.Parameter(entityType.ClrType, "e");
                var notDeleted = Expression.Equal(
                    Expression.Property(e, nameof(SyncedEntity.DeletedAt)),
                    Expression.Constant(null, typeof(DateTime?)));
                modelBuilder.Entity(entityType.ClrType).HasQueryFilter(Expression.Lambda(notDeleted, e));

                // Sync asks "rows of this venue changed since T". One index per table answers that.
                if (entityType.FindProperty("VenueId") is not null)
                    modelBuilder.Entity(entityType.ClrType).HasIndex("VenueId", nameof(SyncedEntity.UpdatedAt));
            }
        }
    }
}
