defmodule Dk6santa.MailTest do
  use Dk6santa.DataCase
  use Mimic

  alias Dk6santa.Mail

  setup :verify_on_exit!

  describe "contacts" do
    alias Dk6santa.Mail.Contact

    @valid_attrs %{email: "some email", name: "some name"}
    @invalid_attrs %{email: nil, name: nil}

    def contact_fixture(attrs \\ %{}) do
      {:ok, contact} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Mail.create_contact()

      contact
    end

    test "list_contacts/0 returns all contacts" do
      contact = contact_fixture()
      assert Mail.list_contacts() == [contact]
    end

    test "get_contact!/1 returns the contact with given id" do
      contact = contact_fixture()
      assert Mail.get_contact!(contact.id) == contact
    end

    test "get_contact_by_santa/1 returns the contact with given santa_id" do
      santa = contact_fixture()
      contact = contact_fixture(%{email: "some email 2", name: "some name 2", santa_id: santa.id})
      assert Mail.get_contact_by_santa(contact.santa_id) == contact
    end

    test "get_contact_by_email/1 returns the contact with given email" do
      contact = contact_fixture()
      assert Mail.get_contact_by_email(contact.email) == contact
    end

    test "create_contact/1 with valid data creates a contact" do
      assert {:ok, %Contact{} = contact} = Mail.create_contact(@valid_attrs)
      assert contact.email == "some email"
      assert contact.name == "some name"
      assert contact.uuid |> is_binary()
    end

    test "create_contact/1 with santa_id creates a contact" do
      attrs = @valid_attrs |> Enum.into(%{santa_id: 2})
      assert {:ok, %Contact{} = contact} = Mail.create_contact(attrs)
      assert contact.email == "some email"
      assert contact.name == "some name"
      assert contact.uuid |> is_binary()
      assert contact.santa_id == 2
    end

    test "create_contact/1 with same email but different name will return old email" do
      contact = contact_fixture()
      contact2 = %{name: "other name"} |> Enum.into(@valid_attrs)
      assert {:ok, ^contact} = Mail.create_contact(contact2)
    end

    test "create_contact/1 with invalid data returns error changeset" do
      assert {:error, :invalid_attrs} = Mail.create_contact(@invalid_attrs)
    end

    test "assign_santa/1 should success when santa_id different with user_id" do
      contact = contact_fixture()
      santa_id = contact.id + 1
      assert {:ok, %{santa_id: ^santa_id}} = Mail.assign_santa(contact.id, santa_id)
    end

    test "assign_santa/1 should error when santa_id is equal to user_id" do
      contact = contact_fixture()

      assert {:error,
              %{errors: [wrong_santa_id: {"Santa ID cannot be the same as current user", []}]}} =
               Mail.assign_santa(contact.id, contact.id)
    end
  end

  describe "letters" do
    alias Dk6santa.Mail.Letter

    @valid_attrs %{
      html: "some html",
      plain: "some plain",
      subject: "some subject",
      to_santa: false
    }
    @invalid_attrs %{html: nil, plain: nil, subject: nil, contact_id: nil}

    def letter_fixture(attrs \\ %{}) do
      {:ok, contact} = Mail.create_contact(%{email: "some email", name: "some name"})

      {:ok, letter} =
        attrs
        |> Map.put(:contact_id, contact.id)
        |> Enum.into(@valid_attrs)
        |> Mail.add_letter()

      letter
    end

    test "list_letters/0 returns all letters" do
      letter = letter_fixture()
      assert Mail.list_letters() == [letter]
    end

    test "get_letter!/1 returns the letter with given id" do
      letter = letter_fixture()
      assert Mail.get_letter!(letter.id) == letter
    end

    test "add_letter/1 with valid data creates a letter" do
      {:ok, contact} = Mail.create_contact(%{email: "some email", name: "some name"})
      attrs = @valid_attrs |> Enum.into(%{contact_id: contact.id})

      Dk6santa.Email
      |> expect(:forward_directly, fn attrs ->
        assert attrs.html == "some html"
        assert attrs.plain == "some plain"
        assert attrs.subject == "some subject"
        assert attrs.contact_id == contact.id
      end)

      Dk6santa.Helper
      |> expect(:spawn_func, fn func ->
        func.()
      end)

      assert {:ok, %Letter{} = letter} = Mail.add_letter(attrs)
      assert letter.html == "some html"
      assert letter.plain == "some plain"
      assert letter.subject == "some subject"
      assert letter.contact_id == contact.id
    end

    test "add_letter/1 with invalid data returns error changeset" do
      reject(&Dk6santa.Email.forward_directly/1)
      assert {:error, %Ecto.Changeset{}} = Mail.add_letter(@invalid_attrs)
    end
  end
end
